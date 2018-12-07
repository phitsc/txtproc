module txtproc.sort_algorithms;

import std.algorithm: cmp, map, sort;
import std.conv : to;
import std.range : join, walkLength;
import std.regex : matchFirst, regex;
import std.string : chomp, icmp;

import txtproc.algorithms;
import txtproc.textalgo;
import txtproc.yesno : YesNo, yesNo;

private auto sortWithinTokenRange(Tokens tokens, bool ignoreCase)
{
    string[] words;

    foreach (token; tokens)
    {
        if (token.type == TokenType.text)
        {
            words ~= token.value;
        }
    }

    sort(words);

    Tokens result;
    size_t index;

    foreach (token; tokens)
    {
        if (token.type == TokenType.text)
        {
            result ~= Token(TokenType.text, words[index]);
            index++;
        }
        else
        {
            result ~= token;
        }
    }

    return result;
}

class SortAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "SortLines", "Sort", "Sort lines of input text alphabetically.", [
                ParameterDescription("Sort left trimmed - y[es] or n[o]", Default("no"))
            ],
            (string text, string[] params, bool ignoreCase) {
                immutable t = yesNo(params[0]) == YesNo.yes;
                return correctLineEndings(text.parseText.lines.sort!((a, b) => ignoreCase ?
                    icmp(t ? a.trimLeft.toText : a.toText, t ? b.trimLeft.toText : b.toText) < 0 :
                    cmp(t ? a.trimLeft.toText : a.toText, t ? b.trimLeft.toText : b.toText) < 0)).map!(a => a.toText).join;
            }
        ));

        add(new Algorithm(
            "SortLinesByLength", "Sort", "Sort lines of input text by line length.", [
                ParameterDescription("Sort left trimmed - y[es] or n[o]", Default("no"))
            ],
            (string text, string[] params, bool ignoreCase) {
                immutable t = yesNo(params[0]) == YesNo.yes;
                return correctLineEndings(text.parseText.lines.sort!((a, b) => (t ? a.trimLeft.toText.chomp.walkLength : a.toText.chomp.walkLength)
                    < (t ? b.trimLeft.toText.chomp.walkLength : b.toText.chomp.walkLength))).map!(a => a.toText).join;
            }
        ));

        add(new Algorithm(
            "SortLinesByNumber", "Sort", "Sort lines of input text by first number found on each line.", [],
            (string text, string[], bool ignoreCase) {
                return correctLineEndings(text.parseText.lines.sort!((a, b) {
                    auto numberRegex = regex(`[-+]?((\b[0-9]+)?\.)?[0-9]+\b`);
                    auto aNumber = a.toText.matchFirst(numberRegex);
                    auto bNumber = b.toText.matchFirst(numberRegex);

                    if (aNumber && bNumber)
                    {
                        return to!double(aNumber.hit) < to!double(bNumber.hit);
                    }
                    else
                    {
                        return aNumber ? true : false;
                    }
                })).map!(a => a.toText).join;
            }
        ));

        add(new Algorithm(
            "SortSentences", "Sort", "Sort sentences of input text alphabetically.", [],
            (string text, string[], bool ignoreCase) {
                return text.parseText.sentences.sort!((a, b) => ignoreCase ?
                    icmp(a.trimLeft.toText, b.trimLeft.toText) < 0 :
                    cmp(a.trimLeft.toText, b.trimLeft.toText) < 0).map!(a => a.toText).join;
            }
        ));

        add(new Algorithm(
            "SortWords", "Sort", "Sort words of input text alphabetically.", [],
            (string text, string[], bool ignoreCase) {
                return text.parseText.sortWithinTokenRange(ignoreCase).toText;
            }
        ));
    }
}
