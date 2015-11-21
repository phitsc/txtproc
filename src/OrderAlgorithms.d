import std.string;
import std.algorithm;

import Algorithms;

class OrderAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "Reverse", "Order", "Reverse order of input text.",
            (string text, string[], bool) {
                return text.dup.reverse.idup;
            }
        ));

        add(new Algorithm(
            "ReverseWords", "Order", "Reverse order within words of input text.",
            (string text, string[], bool) {
                return eachWord(text, (word) => word.dup.reverse.idup);
            }
        ));
    }
}
