import std.string;
import std.uni;
import std.range;
import std.algorithm;

import Algorithms;

class CountAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "Count", "Count",
            (string text, string[], bool, bool) {
                return format("%s characters (incl. whitespace), %s words, %s lines.", text.walkLength, text.split().length, text.splitLines().length);
            }
        ));

        add(new Algorithm(
            "CountAlphabet", "Count",
            (string text, string[], bool ignoreCase, bool reverseOutput) {
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

                foreach (character; sort!((a, b) => reverseOutput ? b.toLower < a.toLower : a.toLower < b.toLower)(dict.keys))
                {
                    result ~= format("%s: %s\n", character, dict[character]);
                }

                return result;
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
    assert(a.find("Count Chars, Words, Lines").process(testText, [], false, false)
        == "90 characters (incl. whitespace), 18 words, 1 lines.");
    assert(a.find("Count Chars, Words, Lines").process(multilineTestText, [], false, false)
        == "169 characters (incl. whitespace), 32 words, 4 lines.");
}
