import std.algorithm;
import std.range;
import std.string;
import std.uni;

import Algorithms;

enum string sentenceSeparatorChars = ".!?";
enum string whitespaceChars        = " \t";

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
            "Toggle", "Capitalisation",
            (string text, string[], bool, bool) {
                string result;

                foreach (character; stride(text, 1))
                {
                    result ~= character.isLower ? character.toUpper : character.toLower;
                }

                return result;
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

        add(new Algorithm(
            "Sentence", "Capitalisation",
            (string text, string[], bool, bool) {
                string result;

                bool newSentence = true;

                foreach (character; stride(text, 1))
                {
                    if (sentenceSeparatorChars.canFind(character))
                    {
                        newSentence = true;

                        result ~= character;
                    }
                    else if (newSentence && !whitespaceChars.canFind(character))
                    {
                        newSentence = false;

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
