import std.string;
import std.algorithm;

import Algorithms;

class OrderAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "Reverse", "Order",
            (string text, string[], bool, bool) {
                auto temp = text.dup;
                temp.reverse;
                return temp.idup;
            }
        ));
    }
}
