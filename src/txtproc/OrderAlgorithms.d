import std.algorithm;
import std.ascii;
import std.array;
import std.conv;
import std.range;
import std.string;
import std.uni;

import Algorithms;
import TextAlgo;

class OrderAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "ReverseLines", "Order", "Reverse order of lines within input text.",
            (string text, string[], bool) {
                auto lines = text.splitLines;
                reverse(lines);
                return lines.join(std.ascii.newline);
            }
        ));

        add(new Algorithm(
            "ReverseSentences", "Order", "Reverse order of sentences within input text.",
            (string text, string[], bool) {
                auto elements = splitTextElements!sentenceSeparatorChars(text, KeepTerminator.yes);
                reverse(elements);
                return elements.join;
            }
        ));

        add(new Algorithm(
            "ReverseWords", "Order", "Reverse order of words within input text.",
            (string text, string[], bool) {
                string result;

                foreach (token; text.parseText.retro)
                {
                    result ~= token.value;
                }

                return result;
            }
        ));

        add(new Algorithm(
            "ReverseCharacters", "Order", "Reverse order of characters within input text.",
            (string text, string[], bool) {
                return text.reverseUni;
            }
        ));

        add(new Algorithm(
            "ReverseCharactersWithinWords", "Order", "Reverse order of characters within words of input text.",
            (string text, string[], bool) {
                string result;

                foreach (token; text.parseText)
                {
                    if (token.type == TokenType.text)
                    {
                        result ~= token.value.reverseUni;
                    }
                    else
                    {
                        result ~= token.value;
                    }
                }

                return result;
            }
        ));
    }
}
