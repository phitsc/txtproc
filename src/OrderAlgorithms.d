import std.string;
import std.algorithm;

import Algorithms;

class OrderAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "Reverse", "Order", "Esrever order of input text.",
            (string text, string[], bool, bool) {
                return text.dup.reverse.idup;
            }
        ));
    }
}
