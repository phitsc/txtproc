module txtproc.count_algorithms;

import std.algorithm : sort;
import std.ascii : newline;
import std.conv : text;
import std.range : array, empty, stride;
import std.regex : matchAll, regex;
import std.string : format;
import std.uni : isAlpha, toLower;

import txtproc.algorithms;
import txtproc.textalgo : count, parseText, TokenType;

class CountAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "Count", "Count", "Count number of characters, words and lines of input text.", [],
            (string text, string[], bool) {
                immutable c = text.count;

                return format("%s characters (incl. whitespace), %s words, %s lines.", c.characters, c.words, c.lines);
            }
        ));

        add(new Algorithm(
            "CountCharacters", "Count", "Count number of characters of input text.", [],
            (string text, string[], bool) {
                return text.count.characters.text;
            }
        ));

        add(new Algorithm(
            "CountWords", "Count", "Count number of words of input text.", [],
            (string text, string[], bool) {
                return text.count.words.text;
            }
        ));

        add(new Algorithm(
            "CountWordOccurence", "Count", "Count how many times each word occurs in the input text.", [],
            (string text, string[], bool ignoreCase) {
                size_t[string] words;

                foreach (token; text.parseText)
                {
                    if (token.type == TokenType.text)
                    {
                        immutable word = ignoreCase ? token.value.toLower : token.value;

                        if (word in words)
                        {
                            words[word]++;
                        }
                        else
                        {
                            words[word] = 1;
                        }
                    }
                }

                return formatDictionary(words);
            }
        ));

        add(new Algorithm(
            "CountSentences", "Count", "Count number of sentences of input text.", [],
            (string text, string[], bool) {
                return text.count.sentences.text;
            }
        ));

        add(new Algorithm(
            "CountLines", "Count", "Count number of sentences of input text.", [],
            (string text, string[], bool) {
                return text.count.lines.text;
            }
        ));

        add(new Algorithm(
            "CountMore", "Count", "Count number of characters, words, sentences and lines of input text.", [],
            (string text, string[], bool) {
                immutable c = text.count;

                return
                    format("%s characters (any)", c.characters) ~ newline ~
                    format("%s alpha-numeric chars", c.alphaNumerics) ~ newline ~
                    format("%s whitespace chars", c.whitespaces) ~ newline ~
                    format("%s words", c.words) ~ newline ~
                    format("%s sentences", c.sentences) ~ newline ~
                    format("%s lines", c.lines);
            }
        ));

        add(new Algorithm(
            "CountCharacterOccurence", "Count", "Count how many times each character occurs in the input text.", [],
            (string text, string[], bool ignoreCase) {
                size_t[dchar] dict;

                foreach (character; text.stride(1))
                {
                    if (character.isAlpha)
                    {
                        immutable alpha = ignoreCase ? character.toLower : character;

                        if (alpha in dict)
                        {
                            dict[alpha]++;
                        }
                        else
                        {
                            dict[alpha] = 1;
                        }
                    }
                }

                return formatDictionary(dict);
            }
        ));

        add(new Algorithm(
            "CountRegex", "Count", "Count how many times the specified regular expression matches.", [
                ParameterDescription("The regular expression to count") ],
            (string text, string[] params, bool ignoreCase) {
                return text.matchAll(regex(params[0], "m" ~ (ignoreCase ? "i" : ""))).array.length.text;
            }
        ));
    }

private:
    static pure auto formatDictionary(A)(A dict)
    {
        string result;

        foreach (key; sort!((a, b) => a.toLower < b.toLower)(dict.keys))
        {
            if (!result.empty) result ~= newline;

            result ~= format("%s: %s", key, dict[key]);
        }

        return result;
    }
}
