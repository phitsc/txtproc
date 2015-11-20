import std.algorithm;
import std.range;
import std.string;
import std.uni;

import Algorithms;

enum string sentenceSeparatorChars = ".!?";
enum string wordSeparatorChars     = " \t\n\r";
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

                foreach (character; text.stride(1))
                {
                    result ~= character.isLower ? character.toUpper : character.toLower;
                }

                return result;
             }
        ));

        add(new Algorithm(
            "Capital", "Capitalisation",
            (string text, string[], bool, bool) {
                return eachWord(text, (word) => word.capitalize);
            }
        ));

        add(new Algorithm(
            "Sentence", "Capitalisation",
            (string text, string[], bool, bool) {
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
            "Snake", "Capitalisation",
            (string text, string[], bool, bool) {
                return eachWord(text, (word) {
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
            "Camel", "Capitalisation",
            (string text, string[], bool, bool) {
                return eachWord(text, (word) {
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

private:
    static string eachWord(string input, string function(string) fun)
    {
        string result;
        string word;

        foreach (character; input.stride(1))
        {
            if (wordSeparatorChars.canFind(character))
            {
                result ~= fun(word);
                result ~= character;
                word = "";
            }
            else
            {
                word ~= character;
            }
        }

        result ~= fun(word);

        return result;
    }
}

version(unittest)
{
    import TestText;
}

unittest
{
    auto a = new CapitalisationAlgorithms;
    assert(a.find("Upper").process(testText, [], false, false)
        == "WAS DU NICHT WILLST DAS MAN DIR TU, DAS FÜG AUCH KEINEM ANDEREN ZU. OHNE FLEISS KEIN PREIS!");
    assert(a.find("Lower").process(testText, [], false, false)
        == "was du nicht willst das man dir tu, das füg auch keinem anderen zu. ohne fleiß kein preis!");
    assert(a.find("Title").process(testText, [], false, false)
        == "Was Du Nicht Willst Das Man Dir Tu, Das Füg Auch Keinem Anderen Zu. Ohne Fleiß Kein Preis!");
    assert(a.find("Sentence").process(testText, [], false, false)
        == "Was du nicht willst das man dir tu, das füg auch keinem anderen zu. Ohne Fleiß kein Preis!");
}
