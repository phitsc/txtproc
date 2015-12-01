import std.algorithm;
import std.range;

import Algorithms;
import TextAlgo;

class SortAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "SortLines", "Sort", "Sort lines of input text alphabetically.",
            (string text, string[], bool ignoreCase) {
                return text.parseText.lines.sort!((a, b) => a.stripLeft.toText < b.stripLeft.toText).map!(a => a.toText).join;
            }
        ));
    }
}
