module txtproc.capitalisation_algorithms;

import std.range : stride;
import std.string;
import std.uni : isUpper, isLower;

import txtproc.algorithms;
import txtproc.textalgo;

private pure auto toSnake(string word)
{
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
}

unittest
{
    assert(toSnake("") == "");
    assert(toSnake("c") == "c");
    assert(toSnake("C") == "C");
    assert(toSnake("camel") == "camel");
    assert(toSnake("Camel") == "Camel");
    assert(toSnake("CamelCase") == "Camel_case");
    assert(toSnake("camelCase") == "camel_case");
    assert(toSnake("camelCaseCamel") == "camel_case_camel");
}

private pure auto toCamel(string word)
{
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
}

unittest
{
    assert(toCamel("") == "");
    assert(toCamel("s") == "s");
    assert(toCamel("S") == "S");
    assert(toCamel("snake") == "snake");
    assert(toCamel("Snake") == "Snake");
    assert(toCamel("Snake_case") == "SnakeCase");
    assert(toCamel("snake_Case") == "snakeCase");
    assert(toCamel("snake_case_snake") == "snakeCaseSnake");
}

class CapitalisationAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "Upper", "Capitalisation", "Change input text to UPPER case.", [],
            (string text, string[], bool) {
                return text.toUpper;
            }
        ));

        add(new Algorithm(
            "Lower", "Capitalisation", "Change input text to lower case.", [],
            (string text, string[], bool) {
                return text.toLower;
            }
        ));

        add(new Algorithm(
            "Toggle", "Capitalisation", "Toggle case of input text.", [],
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
            "Capital", "Capitalisation", "Change Input Text To Capital Case.", [],
            (string text, string[], bool) {
                return text.parseText.map!(a => a.type == TokenType.text ? a.value.capitalize : a.value).join;
            }
        ));

        add(new Algorithm(
            "Sentence", "Capitalisation", "Change input text to sentence case.", [],
            (string text, string[], bool) {
                string result;
                bool sentenceStart = true;

                foreach (token; text.parseText)
                {
                    if (sentenceStart && token.type == TokenType.text)
                    {
                        result ~= token.value.capitalize;
                        sentenceStart = false;
                    }
                    else
                    {
                        if (token.type == TokenType.sentenceTerminator)
                        {
                            sentenceStart = true;
                        }

                        result ~= token.value;
                    }
                }

                return result;
             }
        ));

        add(new Algorithm(
            "Snake", "Capitalisation", "Change input text to snake_case.", [],
            (string text, string[], bool) {
                return text.parseText.map!(a => a.type == TokenType.text ? a.value.toSnake : a.value).join;
            }
        ));

        add(new Algorithm(
            "Camel", "Capitalisation", "Change input text to CamelCase.", [],
            (string text, string[], bool) {
                return text.parseText.map!(a => a.type == TokenType.text ? a.value.toCamel : a.value).join;
            }
        ));
   }
}

unittest
{
    auto a = new CapitalisationAlgorithms();
    assert(a.closest("Upper")[0].process("", [], false) == "");
    assert(a.closest("Lower")[0].process("", [], false) == "");
    assert(a.closest("Toggle")[0].process("", [], false) == "");
    assert(a.closest("Capital")[0].process("", [], false) == "");
    assert(a.closest("Sentence")[0].process("", [], false) == "");
    assert(a.closest("Snake")[0].process("", [], false) == "");
    assert(a.closest("Camel")[0].process("", [], false) == "");
}
