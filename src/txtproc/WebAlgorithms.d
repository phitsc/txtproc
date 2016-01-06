module txtproc.web_algorithms;

import std.algorithm : startsWith;
import std.ascii : newline;
import std.conv : text;
import std.range : stride, walkLength;
import std.regex : regex, replaceAll;

import std.stdio : writeln;

import txtproc.algorithms;
import txtproc.textalgo;

private enum string[string] leetAlphabet =
[
    "a": "4",
    "b": "8",
    "c": "(",
    "d": "|)",
    "e": "3",
    "f": "|=",
    "g": "6",
    "h": "|-|",
    "i": "!",
    "j": "_|",
    "k": "|<",
    "l": "1",
    "m": "|\\/|",
    "n": "|\\|",
    "o": "0",
    "p": "|°",
    "q": "0_",
    "r": "2",
    "s": "5",
    "t": "7",
    "u": "|_|",
    "v": "\\/",
    "w": "\\/\\/",
    "x": "%",
    "y": "`/,",
    "z": "2"
];

class WebAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "ToLeet", "Web", "Convert input text to leet speak.", [],
            (string text, string[], bool) {
                string result;

                foreach (character; text.stride(1))
                {
                    auto c = character.text in leetAlphabet;

                    result ~= c ? *c : character.text;
                }

                return result;
            }
        ));

        add(new Algorithm(
            "FromLeet", "Web", "Convert input text from leet speak.", [],
            (string text, string[], bool) {
                string result;

                while (text.length > 0)
                {
                    auto foundToken = false;

                    foreach (key, value; leetAlphabet)
                    {
                        if (text.startsWith(value))
                        {
                            result ~= key;

                            text = text[value.length .. $];

                            foundToken = true;

                            break;
                        }
                    }

                    if (!foundToken)
                    {
                        result ~= text[0 .. 1];

                        text = text[1 .. $];
                    }
                }

                return result;
            }
        ));

        add(new Algorithm(
            "Tweet", "Web", "Break up input text into tweets.", [
                ParameterDescription("Continuation text for each tweet", Default("")),
            ],
            (string text, string[] options, bool) {
                immutable maxLength = 140 - options[0].walkLength;

                string result;

                size_t sectionLength = 0;

                foreach (token; text.parseText)
                {
                    immutable value = token.value;

                    if (sectionLength + value.walkLength > maxLength)
                    {
                        result ~= options[0] ~ newline ~ value;
                        sectionLength = value.walkLength;
                    }
                    else
                    {
                        result ~= value;
                        sectionLength += value.walkLength;
                    }
                }

                return result;
            }
        ));

        add(new Algorithm(
            "RemoveTags", "Web", "Removes all tags from the input text.", [],
            (string text, string[], bool) {
                return text.replaceAll(regex("<[^>]+>"), "");
            }
        ));
    }
}
