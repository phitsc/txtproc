import std.algorithm;
import std.ascii;
import std.array;
import std.conv;
import std.random;
import std.range;
import std.string;
import std.uni;

import Algorithms;
import TextAlgo;

private auto shuffle(string input)
{
    dchar[] temp;

    foreach (character; input.stride(1))
    {
        temp ~= character;
    }

    temp.randomShuffle;

    return to!string(temp);
}

private auto shuffleWithinTokenRange(Tokens tokens)
{
    size_t[] indices;

    foreach (size_t index, token; tokens)
    {
        if (token.type == TokenType.text)
        {
            indices ~= index;
        }
    }

    indices.randomShuffle;

    Tokens result;
    size_t index;

    foreach (token; tokens)
    {
        if (token.type == TokenType.text)
        {
            result ~= tokens[indices[index]];
            index++;
        }
        else
        {
            result ~= token;
        }
    }

    return result;
}

class OrderAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "ReverseLines", "Order", "Reverse order of lines within input text.", [],
            (string text, string[], bool) {
                auto lines = text.splitLines;
                reverse(lines);
                return lines.join(std.ascii.newline);
            }
        ));

        add(new Algorithm(
            "ReverseSentences", "Order", "Reverse order of sentences within input text.", [],
            (string text, string[], bool) {
                return text.parseText.sentences.retro.map!(a => a.toText).join;
            }
        ));

        add(new Algorithm(
            "ReverseWords", "Order", "Reverse order of words within input text.", [],
            (string text, string[], bool) {
                return text.parseText.retro.toText;
            }
        ));

        add(new Algorithm(
            "ReverseCharacters", "Order", "Reverse order of characters within input text.", [],
            (string text, string[], bool) {
                return text.reverseUni;
            }
        ));

        add(new Algorithm(
            "ReverseCharactersWithinWords", "Order", "Reverse order of characters within words of input text.", [],
            (string text, string[], bool) {
                return text.parseText.map!(a => a.type == TokenType.text ? a.value.reverseUni : a.value).join;
            }
        ));

        add(new Algorithm(
            "Shuffle", "Order", "Shuffle order of characters within input text.", [],
            (string text, string[], bool) {
                return text.shuffle;
            }
        ));

        add(new Algorithm(
            "ShuffleWords", "Order", "Shuffle order of words within input text.", [],
            (string text, string[], bool) {
                return text.parseText.shuffleWithinTokenRange.toText;
            }
        ));

        add(new Algorithm(
            "ShuffleWordsWithinSentence", "Order", "Shuffle order of words within sentences of the input text.", [],
            (string text, string[], bool) {
                return text.parseText.sentences.map!(a => a.shuffleWithinTokenRange.toText).join;
            }
        ));

        add(new Algorithm(
            "ShuffleWithinWords", "Order", "Shuffle order of characters within words of input text.", [],
            (string text, string[], bool) {
                return text.parseText.map!(a => a.type == TokenType.text ? a.value.shuffle : a.value).join;
            }
        ));

    }
}
