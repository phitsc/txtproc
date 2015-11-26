import std.algorithm;
import std.array;
import std.ascii : newline;
import std.conv;
import std.range;
import std.regex;
import std.string;
import std.uni;

import Algorithms;
import TextAlgo;

class CountAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "Count", "Count", "Count number of characters, words and lines of input text.",
            (string text, string[], bool) {
                immutable c = text.counts;

                return format("%s characters (incl. whitespace), %s words, %s lines.", c.character, c.word, c.line);
            }
        ));

        add(new Algorithm(
            "CountMore", "Count", "Count number of characters, words, sentences and lines of input text.",
            (string text, string[], bool) {
                immutable c = text.counts;

                return
                    format("%s characters (any)", c.character) ~ newline ~
                    format("%s alpha-numeric chars", c.alphaNumeric) ~ newline ~
                    format("%s whitespace chars", c.white) ~ newline ~
                    format("%s words", c.word) ~ newline ~
                    format("%s sentences", c.sentence) ~ newline ~
                    format("%s lines", c.line);
            }
        ));

        add(new Algorithm(
            "CountAlphabet", "Count", "Per-character count of input text.",
            (string text, string[], bool ignoreCase) {
                int[dchar] dict;

                foreach (character; text.stride(1))
                {
                    if (character.isAlpha)
                    {
                        immutable alpha = ignoreCase ? character.toLower : character;

                        if (alpha in dict)
                        {
                            dict[alpha]++;
                        }
                        else
                        {
                            dict[alpha] = 1;
                        }
                    }
                }

                string result;

                foreach (character; sort(dict.keys))
                {
                    if (!result.empty) result ~= "\n";

                    result ~= format("%s: %s", character, dict[character]);
                }

                return result;
            }
        ));

        add(new Algorithm(
            "CountRegex", "Count", "Count how many times the specified regular expression matches.",
            (string text, string[] params, bool ignoreCase) {
                if (params.length < 1)
                {
                    throw new Exception("Missing parameter (search text)");
                }

                return to!string(text.matchAll(regex(params[0], "m" ~ (ignoreCase ? "i" : ""))).array.length);
            }
        ));
    }

}

version(unittest)
{
    import TestText;
}

unittest
{
    auto a = new CountAlgorithms;
    assert(a.closest("Count")[0].process(testText, [], false)
        == "90 characters (incl. whitespace), 18 words, 1 lines.");
    assert(a.closest("Count")[0].process(multilineTestText, [], false)
        == "169 characters (incl. whitespace), 32 words, 4 lines.");
}
