import std.algorithm;
import std.array;
import std.range;
import std.string;

import Algorithm;


enum string sentenceSeparatorChars = ".!?";
enum string bracketChars           = "[](){}<>";
enum string quoteChars             = "\"'";
enum string otherPunctuationChars  = ":+-/,;=%&*@#";
enum string wordSeparatorChars     = " \t\n\r" ~ sentenceSeparatorChars ~ bracketChars ~ quoteChars ~ otherPunctuationChars;
enum string whitespaceChars        = " \t";

class Algorithms
{
    void add(Algorithms algorithms)
    {
        foreach (algorithm; algorithms.m_algorithms)
        {
            add(algorithm);
        }
    }

    const(Algorithm) find(string nameish) const
    {
        foreach (algorithm; m_algorithms)
        {
            if (algorithm.name.indexOf(nameish, CaseSensitive.no) != -1)
            {
                return algorithm;
            }
        }

        throw new Exception(format("%s does not match a valid function name.", nameish));
    }

    int opApply(int delegate(const ref Algorithm) func) const
    {
        foreach (algorithm; m_algorithms)
        {
            if (auto result = func(algorithm))
            {
                return result;
            }
        }

        return 0;
    }

protected:
    void add(Algorithm algorithm)
    {
        m_algorithms ~= algorithm;
    }

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

private:
    Algorithm[] m_algorithms;
}
