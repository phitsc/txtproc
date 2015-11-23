import std.algorithm;
import std.array;
import std.conv;
import std.range;
import std.string;
import std.typecons;

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

    const(Algorithm)[] closest(string nameish) const
    {
        Tuple!(size_t, const Algorithm)[] algorithmsByDistance;

        foreach (algorithm; m_algorithms)
        {
            algorithmsByDistance ~= tuple(lcs(algorithm.name.toLower, nameish.toLower).length, algorithm);
        }

        auto indices = new size_t[algorithmsByDistance.length];

        algorithmsByDistance.makeIndex!((a, b) => a[0] > b[0])(indices);

        const(Algorithm)[] result;

        foreach (index; indices)
        {
            result ~= algorithmsByDistance[index][1];
        }

        return result;
    }

    const(Algorithm)[] all() const
    {
        return m_algorithms;
    }

protected:
    void add(Algorithm algorithm)
    {
        m_algorithms ~= algorithm;
    }

    static string eachWord(string input, string function(string) func)
    {
        string result;
        string word;

        foreach (character; input.stride(1))
        {
            if (wordSeparatorChars.canFind(character))
            {
                result ~= func(word);
                result ~= character;
                word = "";
            }
            else
            {
                word ~= character;
            }
        }

        result ~= func(word);

        return result;
    }

private:
    Algorithm[] m_algorithms;

private:
    // longest common subsequence. from rosetta code.
    string lcs(in string a, in string b) const pure
    {
        auto L = new uint[][](a.length + 1, b.length + 1);

        foreach (immutable i; 0 .. a.length)
            foreach (immutable j; 0 .. b.length)
                L[i + 1][j + 1] = (a[i] == b[j]) ? (1 + L[i][j]) : max(L[i + 1][j], L[i][j + 1]);

        Unqual!char[] result;

        for (auto i = a.length, j = b.length; i > 0 && j > 0; )
        {
            if (a[i - 1] == b[j - 1])
            {
                result ~= a[i - 1];
                i--;
                j--;
            }
            else if (L[i][j - 1] < L[i - 1][j])
                    i--;
                else
                    j--;
        }

        result.reverse();

        return result;
    }
}
