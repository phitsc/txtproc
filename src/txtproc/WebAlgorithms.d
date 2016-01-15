module txtproc.web_algorithms;

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
            (string text, string[] params, bool) {
                import std.ascii : newline;
                import std.range : walkLength;
                import std.string : stripRight;

                immutable maxLength = 140 - params[0].walkLength;

                string result;

                size_t sectionLength = 0;

                foreach (token; text.parseText)
                {
                    immutable value = token.value;

                    if (sectionLength + value.walkLength > maxLength)
                    {
                        result = result.stripRight;
                        result ~= params[0] ~ newline ~ value;
                        sectionLength = value.walkLength;
                    }
                    else if (token.type == TokenType.lineTerminator)
                    {
                        result ~= token.value;
                        sectionLength = 0;
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
                import std.regex : regex, replaceAll;
                return text.replaceAll(regex("<[^>]+>"), "");
            }
        ));
    }
}
