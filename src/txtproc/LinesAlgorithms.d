import std.algorithm : filter;
import std.array : insertInPlace, join;
import std.ascii : newline;
import std.conv : text, to;
import std.regex;
import std.string : cmp, chomp, empty, splitLines;
import std.uni : icmp;
import std.typecons : Flag;

//import std.stdio : writeln;
//import std.string : format;

import Algorithm;
import Algorithms;
import TextAlgo;

alias KeepSeparator = Flag!("keepSeparator");
alias IgnoreCase = Flag!("ignoreCase");


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
            ],
            (string text, string[] options, bool ignoreCase) {
                return text.parseText.lines.map!(a => a.appendTextToLine(options[0])).map!(a => a.toText).join;
            }
        ));

        add(new Algorithm(
            "PrependToLines", "Lines", "Prepend (prefix) some text to each line of the input text.", [
                ParameterDescription("Text to prepend to each line"),
            ],
            (string text, string[] options, bool ignoreCase) {
                return text.parseText.lines.map!(a => a.prependTextToLine(options[0])).map!(a => a.toText).join;
            }
        ));

        add(new Algorithm(
            "PrependLineNumbers", "Lines", "Prepend (prefix) each line of input text with a line number.", [
                ParameterDescription("Line number format string (use # for line number)", Default("#")),
                ParameterDescription("On what line number to start", Default("1")),
                ParameterDescription("How much to increment on each line", Default("1")),
                ParameterDescription("Base to use for line numbers (can be any of b(inary), o(ctal), d(ecimal) or he(x|X)", Default("d")),
            ],
            (string text, string[] options, bool ignoreCase) {
                if (!"bodxX".canFind(options[3]))
                {
                    throw new Exception(options[3] ~ " is not a valid base.");
                }

                auto r = regex("[#]+");
                auto captures = options[0].matchFirst(r);
                immutable fmt = captures.empty ? "" : options[0].replaceFirst(r, "%" ~ captures.hit.length.text ~ options[3]);
                immutable start = to!size_t(options[1]);
                immutable increment = to!size_t(options[2]);

                size_t lineNumber = start;
                return text.parseText.lines.map!((a) {
                        const result = a.prependTextToLine(format(fmt, lineNumber));
                        lineNumber += increment;
                        return result;
                    }).map!(a => a.toText).join;
            }
        ));
    }
}
