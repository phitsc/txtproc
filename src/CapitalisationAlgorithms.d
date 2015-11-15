import std.string;
import std.uni;
import std.range;

import Algorithms;

class CapitalisationAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "Upper", "Capitalisation",
            (string text, string[], bool, bool) {
                return text.toUpper;
            }
        ));

        add(new Algorithm(
            "Lower", "Capitalisation",
            (string text, string[], bool, bool) {
                return text.toLower;
            }
        ));

        add(new Algorithm(
            "Title", "Capitalisation",
            (string text, string[], bool, bool) {
                string result;

                bool newWord = true;

                foreach (character; stride(text, 1))
                {
                    if (character.isWhite)
                    {
                        newWord = true;

                        result ~= character;
                    }
                    else if (newWord)
                    {
                        newWord = false;

                        result ~= character.toUpper;
                    }
                    else
                    {
                        result ~= character;
                    }
                }

                return result;
             }
        ));
   }

}
