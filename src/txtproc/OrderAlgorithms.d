import std.algorithm;
import std.ascii;
import std.array;
import std.conv;
import std.range;
import std.string;
import std.uni;

import Algorithms;
import TextAlgo;

string reverseUni(string text)
{
    return text.byGrapheme.array.retro.byCodePoint.text;
}

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
            "ReverseCharacters", "Order", "Reverse order of characters within input text.",
            (string text, string[], bool) {
                return text.reverseUni;
            }
        ));

        add(new Algorithm(
            "ReverseCharactersWithinWords", "Order", "Reverse order of characters within words of input text.",
            (string text, string[], bool) {
                return text.eachWord(word => word.reverseUni);
            }
        ));
    }
}
