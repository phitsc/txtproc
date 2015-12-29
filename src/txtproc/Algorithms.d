import std.algorithm : canFind, makeIndex, max, reverse;
import std.string : icmp, toLower, toUpper;
import std.typecons : Tuple, tuple, Unqual;

import Algorithm;

class Algorithms
{
    void add(Algorithms algorithms)
    {
        foreach (algorithm; algorithms.m_algorithms)
        {
            add(algorithm);
        }
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
        const(Algorithm)[] result;

        Tuple!(size_t, const Algorithm)[] algorithmsByDistance;

        foreach (algorithm; m_algorithms)
        {
            if (icmp(algorithm.name, nameish) == 0)
            {
                result ~= algorithm; // prefer exact match
            }
            else
            {
                algorithmsByDistance ~= tuple(lcs(algorithm.name.toLower, nameish.toLower).length, algorithm);
            }
        }

        auto indices = new size_t[algorithmsByDistance.length];

        algorithmsByDistance.makeIndex!((a, b) => a[0] > b[0])(indices);

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
        // Algorithm names must be unique
        assert(!m_algorithms.canFind(algorithm));

        m_algorithms ~= algorithm;
    }

private:
    Algorithm[] m_algorithms;

private:
    // longest common subsequence. from rosetta code.
    string lcs(in string a, in string b) const pure
    {
        import std.conv : text;

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

        return result.text;
    }
}
