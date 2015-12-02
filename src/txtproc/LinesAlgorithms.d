import std.algorithm : filter;
import std.array : join;
import std.string : chomp, empty;

import Algorithms;
import TextAlgo;

class LinesAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "RemoveEmptyLines", "Lines", "Removes empty lines from input text.",
            (string text, string[], bool) {
                return text.parseText.lines.filter!(a => !a.trimLeft.toText.chomp.empty).map!(a => a.toText).join;
            }
        ));
    }
}
