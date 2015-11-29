import std.algorithm;
import std.range;
import std.string;
import std.uni;

import Algorithms;
import TextAlgo;

class CapitalisationAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "Upper", "Capitalisation", "Change input text to UPPER case.",
            (string text, string[], bool) {
                return text.toUpper;
            }
        ));

        add(new Algorithm(
            "Lower", "Capitalisation", "Change input text to lower case.",
            (string text, string[], bool) {
                return text.toLower;
            }
        ));

        add(new Algorithm(
            "Toggle", "Capitalisation", "Toggle case of input text.",
            (string text, string[], bool) {
                string result;

                foreach (character; text.stride(1))
                {
                    result ~= character.isLower ? character.toUpper : character.toLower;
                }

                return result;
             }
        ));

        add(new Algorithm(
            "Capital", "Capitalisation", "Change Input Text To Capital Case.",
            (string text, string[], bool) {
                return text.parseText.map!(a => a.type == TokenType.text ? a.value.capitalize : a.value).join;
            }
        ));

        add(new Algorithm(
            "Sentence", "Capitalisation", "Change input text to sentence case.",
            (string text, string[], bool) {
                string result;

                bool newSentence = true;

                foreach (character; text.stride(1))
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

        add(new Algorithm(
            "Snake", "Capitalisation", "Change input text to snake_case.",
            (string text, string[], bool) {
                return text.eachWord((word) {
                    string result;
                    bool wasLower = false;

                    foreach (character; word.stride(1))
                    {
                        if (character.isUpper)
                        {
                            if (wasLower)
                            {
                                result ~= format("_%s", character.toLower);
                            }
                            else
                            {
                                result ~= character;
                            }

                            wasLower = false;
                        }
                        else
                        {
                            result ~= character;
                            wasLower = true;
                        }
                    }

                    return result;
                });
            }
        ));

        add(new Algorithm(
            "Camel", "Capitalisation", "Change input text to CamelCase.",
            (string text, string[], bool) {
                return text.eachWord((word) {
                    bool isFirst = true;
                    return word.canFind("_") ? word.split("_").map!((w) {
                        if (isFirst)
                        {
                            isFirst = false;
                            return w; // leave first word as it is
                        }
                        else
                        {
                            return w.capitalize;
                        }
                    }).join : word;
                });
            }
        ));
   }
}
