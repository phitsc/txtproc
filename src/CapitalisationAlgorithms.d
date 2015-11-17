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

enum string testText = "was du nicht willst das man dir tu, das füg auch keinem anderen zu. ohne Fleiß kein Preis!";

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
