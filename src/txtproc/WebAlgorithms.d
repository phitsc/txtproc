module txtproc.web_algorithms;

import std.algorithm : startsWith;
import std.ascii : newline;
import std.conv : text;
import std.range : walkLength;
import std.regex : regex, replaceAll;

import std.stdio : writeln;

import txtproc.algorithms;
import txtproc.textalgo;


class WebAlgorithms : Algorithms
{
    this()
    {
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
