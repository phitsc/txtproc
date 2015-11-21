import std.algorithm;
import std.ascii;
import std.string;

import Algorithms;

class OrderAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "ReverseLines", "Order", "Reverse order of lines within input text.",
            (string text, string[], bool) {
                return text.splitLines.reverse.join(std.ascii.newline);
            }
        ));

        add(new Algorithm(
            "ReverseCharacters", "Order", "Reverse order of characters within input text.",
            (string text, string[], bool) {
                return text.dup.reverse.idup;
            }
        ));

        add(new Algorithm(
            "ReverseCharactersWithinWords", "Order", "Reverse order of characters within words of input text.",
            (string text, string[], bool) {
                return eachWord(text, (word) => word.dup.reverse.idup);
            }
        ));
    }
}
