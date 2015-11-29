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
                return text.parseText.sentences.retro.map!(a => a.map!(a => a.value).join).join;
            }
        ));

        add(new Algorithm(
            "ReverseWords", "Order", "Reverse order of words within input text.",
            (string text, string[], bool) {
                return text.parseText.retro.map!(a => a.value).join;
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
                return text.parseText.map!(a => a.type == TokenType.text ? a.value.reverseUni : a.value).join;
            }
        ));
    }
}
