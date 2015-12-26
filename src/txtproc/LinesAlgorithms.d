import std.algorithm : filter, max, reduce;
import std.array : array, insertInPlace, join;
import std.ascii : newline;
import std.conv : text, to;
import std.range : retro, stride, walkLength;
import std.regex;
import std.string : cmp, chomp, empty, indexOf, lastIndexOf, leftJustify, rightJustify, splitLines, CaseSensitive;
import std.uni : icmp;
import std.typecons : Flag;

import Algorithm;
import Algorithms;
import TextAlgo;
import YesNo : YesNo, yesNo;

alias KeepSeparator = Flag!("keepSeparator");
alias IgnoreCase = Flag!("ignoreCase");

// supports ignoring case
private string[] split(string input, string separator, IgnoreCase ignoreCase, KeepSeparator keepSeparator)
{
    string[] result;

    size_t currentIndex = 0;

    if (input.length > separator.length && separator.length > 0)
    {
        for (size_t i = 0; i <= input.length - separator.length; ++i)
        {
            immutable match = ignoreCase ?
                icmp(input[i .. i + separator.length], separator) == 0 :
                cmp(input[i .. i + separator.length], separator) == 0;

            if (match)
            {
                result ~= keepSeparator ? input[currentIndex .. i + separator.length] : input[currentIndex .. i];
                currentIndex = i + separator.length;
                i = currentIndex;
            }
        }
    }

    if (currentIndex < input.length)
    {
        result ~= input[currentIndex .. $];
    }

    return result;
}

unittest
{
    // heed case, drop separator
    assert("Simple,to,split".split(",", IgnoreCase.no, KeepSeparator.no) == ["Simple","to","split"]);
    assert("Multiäöüchar äöü\tseparator äöü Hello worldÄöü!".split("äöü", IgnoreCase.no, KeepSeparator.no)
        == ["Multi","char ","\tseparator ", " Hello worldÄöü!"]);
    assert("".split(",", IgnoreCase.no, KeepSeparator.no) == []);
    assert("short".split("verylong", IgnoreCase.no, KeepSeparator.no) == ["short"]);
    assert("text which hasn't got the separator".split(",", IgnoreCase.no, KeepSeparator.no) == ["text which hasn't got the separator"]);
    assert("Empty separator leaves text as is".split("", IgnoreCase.no, KeepSeparator.no) == ["Empty separator leaves text as is"]);
    assert("Separated€öÜby€öÜunicode€öÜcharacters. And some  €öÜ  white\tspace.".split("€öÜ", IgnoreCase.no, KeepSeparator.no)
        == ["Separated", "by", "unicode", "characters. And some  ", "  white\tspace."]);
    assert("Multi char€$terminator€$at€$the€$end€$".split("€$", IgnoreCase.no, KeepSeparator.no)
        == ["Multi char", "terminator", "at", "the", "end"]);

    // ignore case, drop separator
    assert("Simple,to,split".split(",", IgnoreCase.yes, KeepSeparator.no) == ["Simple","to","split"]);
    assert("Multiäöüchar äÖü\tseparator ÄÖü Hello worldÄöü!".split("äöü", IgnoreCase.yes, KeepSeparator.no)
        == ["Multi","char ","\tseparator ", " Hello world", "!"]);
    assert("".split(",", IgnoreCase.yes, KeepSeparator.no) == []);
    assert("short".split("verylong", IgnoreCase.yes, KeepSeparator.no) == ["short"]);
    assert("text which hasn't got the separator".split(",", IgnoreCase.yes, KeepSeparator.no) == ["text which hasn't got the separator"]);
    assert("Empty separator leaves text as is".split("", IgnoreCase.yes, KeepSeparator.no) == ["Empty separator leaves text as is"]);
    assert("Separated€öÜby€öÜunicode€öÜcharacters. And some  €öÜ  white\tspace.".split("€Öü", IgnoreCase.yes, KeepSeparator.no)
        == ["Separated", "by", "unicode", "characters. And some  ", "  white\tspace."]);
    assert("Multi char€$terminator€$at€$the€$end€$".split("€$", IgnoreCase.yes, KeepSeparator.no)
        == ["Multi char", "terminator", "at", "the", "end"]);

    // heed case, keep separator
    assert("Simple,to,split".split(",", IgnoreCase.no, KeepSeparator.yes) == ["Simple,","to,","split"]);
    assert("Multiäöüchar äöü\tseparator äöü Hello worldÄöü!".split("äöü", IgnoreCase.no, KeepSeparator.yes)
        == ["Multiäöü","char äöü","\tseparator äöü", " Hello worldÄöü!"]);
    assert("".split(",", IgnoreCase.no, KeepSeparator.yes) == []);
    assert("short".split("verylong", IgnoreCase.no, KeepSeparator.yes) == ["short"]);
    assert("text which hasn't got the separator".split(",", IgnoreCase.no, KeepSeparator.yes) == ["text which hasn't got the separator"]);
    assert("Empty separator leaves text as is".split("", IgnoreCase.no, KeepSeparator.yes) == ["Empty separator leaves text as is"]);
    assert("Separated€öÜby€öÜunicode€öÜcharacters. And some  €öÜ  white\tspace.".split("€öÜ", IgnoreCase.no, KeepSeparator.yes)
        == ["Separated€öÜ", "by€öÜ", "unicode€öÜ", "characters. And some  €öÜ", "  white\tspace."]);
    assert("Multi char€$terminator€$at€$the€$end€$".split("€$", IgnoreCase.no, KeepSeparator.yes)
        == ["Multi char€$", "terminator€$", "at€$", "the€$", "end€$"]);

    // ignore case, keep separator
    assert("Simple,to,split".split(",", IgnoreCase.yes, KeepSeparator.yes) == ["Simple,","to,","split"]);
    assert("Multiäöüchar äÖü\tseparator ÄÖü Hello worldÄöü!".split("äöü", IgnoreCase.yes, KeepSeparator.yes)
        == ["Multiäöü","char äÖü","\tseparator ÄÖü", " Hello worldÄöü", "!"]);
    assert("".split(",", IgnoreCase.yes, KeepSeparator.yes) == []);
    assert("short".split("verylong", IgnoreCase.yes, KeepSeparator.yes) == ["short"]);
    assert("text which hasn't got the separator".split(",", IgnoreCase.yes, KeepSeparator.yes) == ["text which hasn't got the separator"]);
    assert("Empty separator leaves text as is".split("", IgnoreCase.yes, KeepSeparator.yes) == ["Empty separator leaves text as is"]);
    assert("Separated€öÜby€öÜunicode€öÜcharacters. And some  €öÜ  white\tspace.".split("€Öü", IgnoreCase.yes, KeepSeparator.yes)
        == ["Separated€öÜ", "by€öÜ", "unicode€öÜ", "characters. And some  €öÜ", "  white\tspace."]);
    assert("Multi char€$terminator€$at€$the€$end€$".split("€$", IgnoreCase.yes, KeepSeparator.yes)
        == ["Multi char€$", "terminator€$", "at€$", "the€$", "end€$"]);
}

private auto formatLineWithNumber(string fmtString, string line, int number, string base)
{
    static auto numberRegex = regex("[#]+");
    auto numberCaptures = fmtString.matchFirst(numberRegex);
    auto fmt = numberCaptures.empty ? fmtString : fmtString.replaceFirst(numberRegex, format("%" ~ numberCaptures.hit.length.text ~ base, number));

    static auto lineRegex = regex("\\$");
    auto lineCaptures = fmt.matchFirst(lineRegex);
    return lineCaptures.empty ? fmt : fmt.replaceFirst(lineRegex, line);
}

private auto maxLineLength(const(Token[][]) lines)
{
    return reduce!((res, t) => max(res, t.toText.chomp.walkLength))(cast(size_t)0, lines);
}

private enum End
{
    left,
    right,
    both
}

private End whichEnd(string end)
{
    if (!icmp(end, "l") || !icmp(end, "left"))
    {
        return End.left;
    }
    else if (!icmp(end, "r") || !icmp(end, "right"))
    {
        return End.right;
    }
    else if (!icmp(end, "b") || !icmp(end, "both"))
    {
        return End.both;
    }
    else
    {
        throw new Exception(end ~ " does not specify a valid line end.");
    }
}

class LinesAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "RemoveEmptyLines", "Lines", "Removes empty lines from input text.", [],
            (string text, string[], bool) {
                return text.parseText.lines.filter!(a => !a.trimLeft.toText.chomp.empty).map!(a => a.toText).join;
            }
        ));

        add(new Algorithm(
            "RemoveExtraEmptyLines", "Lines", "Reduces consecutive empty lines to one empty line.", [],
            (string text, string[], bool) {

                bool emptyLine;

                return text.parseText.lines.filter!((a) {
                    if (a.trimLeft.toText.chomp.empty)
                    {
                        if (!emptyLine)
                        {
                            emptyLine = true;
                            return true;
                        }
                        else
                        {
                            return false;
                        }
                    }
                    else
                    {
                        emptyLine = false;
                        return true;
                    }
                }).map!(a => a.toText).join;
            }
        ));

        add(new Algorithm(
            "RemoveDuplicateLines", "Lines", "Removes duplicate lines from input text.", [
                ParameterDescription("A format string to add the number of duplications + 1 to each line (use # for duplicate count, $ for line contents)", Default("$")),
            ],
            (string text, string[] options, bool) {
                int[string] uniqueLines;

                return text.parseText.lines.filter!((a) {
                    immutable line = a.toText.chomp;

                    if (!(line in uniqueLines))
                    {
                        uniqueLines[line] = 1;
                        return true;
                    }
                    else
                    {
                        uniqueLines[line] += 1;
                        return false;
                    }
                }).array.eachLineJoin(a => formatLineWithNumber(options[0], a, uniqueLines[a], "d"));
            }
        ));

        add(new Algorithm(
            "RemoveLinesContaining", "Lines", "Removes lines containing a specified sub-text from input text.", [
                ParameterDescription("The sub-text to be found on lines to remove"),
            ],
            (string text, string[] options, bool ignoreCase) {
                return text.parseText.lines.filter!(a => a.toText.indexOf(options[0], ignoreCase ? CaseSensitive.no : CaseSensitive.yes) == -1).map!(a => a.toText).join;
            }
        ));

        add(new Algorithm(
            "RemoveLinesContainingRegex", "Lines", "Removes lines containing a specified regular expression from input text.", [
                ParameterDescription("The regular expression to be found on lines to remove"),
            ],
            (string text, string[] options, bool ignoreCase) {
                return text.parseText.lines.filter!(a => !a.toText.matchFirst(regex(options[0], ignoreCase ? "i" : ""))).map!(a => a.toText).join;
            }
        ));

        add(new Algorithm(
            "SplitIntoLines", "Lines", "Split input text into lines using the specified separator string.", [
                ParameterDescription("The string by which to separate the input text into lines"),
            ],
            (string text, string[] options, bool ignoreCase) {
                return text.split(options[0], ignoreCase ? IgnoreCase.yes : IgnoreCase.no, KeepSeparator.no).join(newline);
            }
        ));

        add(new Algorithm(
            "JoinLines", "Lines", "Join lines of input text into one single line.", [
                ParameterDescription("Text to put between each joined line", Default("")),
            ],
            (string text, string[] options, bool ignoreCase) {
                return text.splitLines.join(options[0]);
            }
        ));

        add(new Algorithm(
            "AppendToLines", "Lines", "Append some text to each line of the input text.", [
                ParameterDescription("Text to append to each line"),
                ParameterDescription("Fill character to pad up to length of longest line", Default("")),
            ],
            (string text, string[] options, bool ignoreCase) {
                const lines = text.parseText.lines;

                if (options[1].empty)
                {
                    return lines.eachLineJoin(a => a ~ options[0]);
                }
                else
                {
                    return lines.eachLineJoin(a => a.leftJustify(lines.maxLineLength, options[1][0]) ~ options[0]);
                }
            }
        ));

        add(new Algorithm(
            "PrependToLines", "Lines", "Prepend (prefix) some text to each line of the input text.", [
                ParameterDescription("Text to prepend to each line"),
                ParameterDescription("Fill character to pad up to length of longest line", Default("")),
            ],
            (string text, string[] options, bool ignoreCase) {
                const lines = text.parseText.lines;

                if (options[1].empty)
                {
                    return text.parseText.lines.eachLineJoin(a => options[0] ~ a);
                }
                else
                {
                    return lines.eachLineJoin(a => options[0] ~ a.rightJustify(lines.maxLineLength, options[1][0]));
                }
            }
        ));

        add(new Algorithm(
            "AddLineNumbers", "Lines", "Add line numbers to each line of input text.", [
                ParameterDescription("Line number format string (use # for line number, $ for line contents)", Default("#$")),
                ParameterDescription("On what line number to start", Default("1")),
                ParameterDescription("How much to increment on each line", Default("1")),
                ParameterDescription("Base to use for line numbers (can be any of b(inary), o(ctal), d(ecimal) or he(x|X)", Default("d")),
            ],
            (string text, string[] options, bool ignoreCase) {
                if (!"bodxX".canFind(options[3]))
                {
                    throw new Exception(options[3] ~ " is not a valid base.");
                }

                immutable increment = to!int(options[2]);

                auto lineNumber = to!int(options[1]);
                return text.parseText.lines.eachLineJoin((a) {
                        const result = formatLineWithNumber(options[0], a, lineNumber, options[3]);
                        lineNumber += increment;
                        return result;
                    });
            }
        ));

        add(new Algorithm(
            "TrimLine", "Lines", "Removes a specified number of characters from the beginning and/or end of each line.", [
                ParameterDescription("Number of characters to remove at the beginning of each line"),
                ParameterDescription("Number of characters to remove at the end of each line", Default("0")),
            ],
            (string text, string[] options, bool ignoreCase) {
                return text.parseText.lines.eachLineJoin((a) {
                        immutable left = max(0, to!int(options[0]));
                        immutable right = a.walkLength - max(0, to!int(options[1]));

                        string result;
                        size_t index = 0;

                        foreach (character; a.stride(1))
                        {
                            if (index >= right)
                            {
                                break;
                            }
                            else if (index >= left)
                            {
                                result ~= character;
                            }

                            ++index;
                        }

                        return result;

                        // if splices would work with unicode characters
                        //return (left + right) < a.length ? a[left .. $ - right] : "";
                    });
            }
        ));

        add(new Algorithm(
            "RemoveWords", "Lines", "Removes a specified number of words from the beginning and/or end of each line.", [
                ParameterDescription("Number of words to remove at the beginning of each line"),
                ParameterDescription("Number of words to remove at the end of each line", Default("0")),
            ],
            (string text, string[] options, bool ignoreCase) {
                return text.parseText.lines.eachLineJoinT((line) {
                    auto left = max(0, to!int(options[0]));
                    auto right = max(0, to!int(options[1]));

                    pure size_t getIndex(R)(int count, R range)
                    {
                        size_t index = 0;

                        if (count > 0)
                        {
                            foreach (token; range)
                            {
                                if (token.type == TokenType.text)
                                {
                                    if (--count == 0)
                                    {
                                        break;
                                    }
                                }

                                index++;
                            }

                            index++;
                        }

                        return index;
                    }

                    immutable leftIndex = getIndex(left, line);
                    immutable rightIndex = getIndex(right, line.retro);

                    return (leftIndex + rightIndex) < line.length ? line[leftIndex .. $ - rightIndex].dup : [ Token(TokenType.none, "") ];
                }).map!(a => a.toText).join;
            }
        ));

        add(new Algorithm(
            "Strip", "Lines", "Removes whitespace from the beginning and/or end of each line.", [
                ParameterDescription("On which end to remove whitespace - l[eft], r[ight] or b[oth]", Default("both")),
            ],
            (string text, string[] options, bool ignoreCase) {
                return text.parseText.lines.eachLineJoinT((line) {
                    immutable end = whichEnd(options[0]);

                    pure size_t getIndex(R)(R range)
                    {
                        size_t index = 0;

                        foreach (token; range)
                        {
                            if (token.type != TokenType.whitespace)
                            {
                                break;
                            }

                            index++;
                        }

                        return index;
                    }

                    immutable leftIndex = (end == End.left || end == End.both) ? getIndex(line) : 0;
                    immutable rightIndex = (end == End.right || end == End.both) ? getIndex(line.retro) : 0;

                    return (leftIndex + rightIndex) < line.length ? line[leftIndex .. $ - rightIndex].dup : [ Token(TokenType.none, "") ];
                }).map!(a => a.toText).join;
            }
        ));

        add(new Algorithm(
            "StripNonWordCharacters", "Lines", "Removes non-word characters from the beginning and/or end of each line.", [
                ParameterDescription("On which end to remove non-word characters - l[eft], r[ight] or b[oth]", Default("both")),
            ],
            (string text, string[] options, bool ignoreCase) {
                return text.parseText.lines.eachLineJoinT((line) {
                    immutable end = whichEnd(options[0]);

                    pure size_t getIndex(R)(R range)
                    {
                        size_t index = 0;

                        foreach (token; range)
                        {
                            if (token.type == TokenType.text)
                            {
                                break;
                            }

                            index++;
                        }

                        return index;
                    }

                    immutable leftIndex = (end == End.left || end == End.both) ? getIndex(line) : 0;
                    immutable rightIndex = (end == End.right || end == End.both) ? getIndex(line.retro) : 0;

                    return (leftIndex + rightIndex) < line.length ? line[leftIndex .. $ - rightIndex].dup : [ Token(TokenType.none, "") ];
                }).map!(a => a.toText).join;
            }
        ));

        add(new Algorithm(
            "RemoveTo", "Lines", "Removes everything before and/or after the sub-text specified (optionally including the sub-text).", [
                ParameterDescription("The sub-text to search for on each line"),
                ParameterDescription("On which end to remove - l[eft], r[ight] or b[oth]", Default("left")),
                ParameterDescription("Remove the sub-text as well? - y[es] or n[o]", Default("no")),
            ],
            (string text, string[] options, bool ignoreCase) {
                return text.parseText.lines.eachLineJoin((a) {
                        immutable end = whichEnd(options[1]);
                        immutable yn = yesNo(options[2]);

                        size_t from = 0;

                        if (end == End.left || end == End.both)
                        {
                            immutable index = a.indexOf(options[0], ignoreCase ? CaseSensitive.no : CaseSensitive.yes);

                            if (index != -1)
                            {
                                from = (yn == YesNo.no) ? index : index + options[0].length;
                            }
                        }

                        auto to = a.length;

                        if (end == End.right || end == End.both)
                        {
                            immutable index = a.lastIndexOf(options[0], ignoreCase ? CaseSensitive.no : CaseSensitive.yes);

                            if (index != -1)
                            {
                                to = (yn == YesNo.no) ? index + options[0].length : index;
                            }
                        }

                        return a[from .. to];
                    });
            }
        ));

        add(new Algorithm(
            "ExtractColumn", "Lines", "Extracts the specified column delimited by the specified text out of each line.", [
                ParameterDescription("Column number (1-based)"),
                ParameterDescription("Column delimiter text", Default(",")),
            ],
            (string text, string[] params, bool ignoreCase) {
                return text.parseText.lines.eachLineJoin((a) {
                    const columns = a.split(params[1], ignoreCase ? IgnoreCase.yes : IgnoreCase.no, KeepSeparator.no);
                    immutable columnNumber = to!int(params[0]);
                    return (columnNumber - 1) < columns.length ? columns[columnNumber - 1] : "";
                });
            }
        ));
    }
}
