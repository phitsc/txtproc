module txtproc.order_algorithms;

import std.algorithm : map, reverse;
import std.conv : to;
import std.random : randomShuffle;
import std.range : array, retro, walkLength;
import std.string : join;

import txtproc.algorithms;
import txtproc.textalgo;
import txtproc.yesno : YesNo, yesNo;

version (unittest)
{

struct TestRand
{
    enum isUniformRandom = true;
    enum empty = false;

    size_t front()
    {
        return m_current;
    }

    void popFront()
    {
        ++m_current;
    }

    private size_t m_current = 0;
}

TestRand rndGen;

}
else
{

import std.random : rndGen;

}

private auto shuffle(string input, bool keepEnds = false)
{
    if (input.walkLength > 1)
    {
        dchar[] temp;

        foreach (character; input.chars)
        {
            temp ~= character;
        }

        if (keepEnds)
        {
            temp[1 .. $-1].randomShuffle(rndGen);
        }
        else
        {
            temp.randomShuffle(rndGen);
        }

        return to!string(temp);
    }
    else
    {
        return input;
    }
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

    indices.randomShuffle(rndGen);

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
                import std.string : join, splitLines;
                import std.ascii : newline;
                auto lines = text.splitLines;
                reverse(lines);
                return lines.join(newline);
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
                import std.string : replace;
                const temp = text.replace("\r\n", "\n");
                return temp.shuffle;
            }
        ));

        add(new Algorithm(
            "ShuffleWords", "Order", "Shuffle order of words within input text.", [],
            (string text, string[], bool) {
                return text.parseText.shuffleWithinTokenRange.toText;
            }
        ));

        add(new Algorithm(
            "ShuffleLines", "Order", "Shuffle order of lines within input text.", [],
            (string text, string[], bool) {
                auto temp = text.parseText.lines.map!(a => a.toText).array;
                temp.randomShuffle(rndGen);
                return temp.join;
            }
        ));

        add(new Algorithm(
            "ShuffleSentences", "Order", "Shuffle order of sentences within input text.", [],
            (string text, string[], bool) {
                auto temp = text.parseText.sentences.map!(a => a.toText).array;
                temp.randomShuffle(rndGen);
                return temp.join;
            }
        ));

        add(new Algorithm(
            "ShuffleWordsWithinSentence", "Order", "Shuffle order of words within sentences of the input text.", [],
            (string text, string[], bool) {
                return text.parseText.sentences.map!(a => a.shuffleWithinTokenRange.toText).join;
            }
        ));

        add(new Algorithm(
            "ShuffleWithinWords", "Order", "Shuffle order of characters within words of input text.", [
                ParameterDescription("Typoglycemia - y[es], n[o]", Default("no")),
            ],
            (string text, string[] params, bool) {
                return text.parseText.map!(a => a.type == TokenType.text ? a.value.shuffle(yesNo(params[0]) == YesNo.yes) : a.value).join;
            }
        ));

    }
}
