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
            "Count Chars, Words, Lines", "Count",
            (string text, string[], bool, bool) {
                return format("%s characters (incl. whitespace), %s words, %s lines.", text.walkLength, text.split().length, text.splitLines().length);
            }
        ));

        add(new Algorithm(
            "Count Alphabet", "Count",
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

                foreach (character; sort!((a, b) => reverseOutput ? b < a : a < b)(dict.keys.sort))
                {
                    result ~= format("%s: %s\n", character, dict[character]);
                }

                return result;
            }
        ));
    }

}
