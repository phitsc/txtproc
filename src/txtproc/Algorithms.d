module txtproc.algorithms;

import std.algorithm : canFind, makeIndex, max, reverse;
import std.string : icmp, toLower, toUpper;
import std.typecons : Tuple, tuple, Unqual;

public import txtproc.algorithm;

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
        Tuple!(double, const Algorithm)[] algorithmsByDistance;

        foreach (algorithm; m_algorithms)
        {
            algorithmsByDistance ~= tuple(jwd(algorithm.name.toLower, nameish.toLower), algorithm);
        }

        auto indices = new size_t[algorithmsByDistance.length];

        algorithmsByDistance.makeIndex!((a, b) => a[0] > b[0])(indices);

        const(Algorithm)[] result;

        foreach (index; indices)
        {
            import debugflag;
            import std.conv : text;
            if (printDebugOutput) writeline(algorithmsByDistance[index][1].name ~ " : " ~ algorithmsByDistance[index][0].text);
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
    // Jaro-Winkler distance
    enum weightThreshold = 0.7;
    enum prefixThreshold = 4;

    static double jwd(string a, string b) pure
    {
        import std.algorithm : min, max;
        import std.conv : to;

        if (a.length == 0)
        {
            return b.length == 0 ? 1.0 : 0.0;
        }

        int searchRange = max(0, max(a.length, b.length) / 2 - 1); // signed for use in min/max

        auto matchesA = new bool[a.length];
        auto matchesB = new bool[b.length];

        auto commonCount = 0;

        for (auto i = 0; i < a.length; ++i)
        {
            int start = max(0, i - searchRange);
            int end = min(i + searchRange + 1, b.length);

            for (auto j = start; j < end; ++j)
            {
                if (matchesB[j]) continue;
                if (a[i] != b[j]) continue;

                matchesA[i] = true;
                matchesB[j] = true;
                ++commonCount;
                break;
            }
        }

        if (commonCount == 0) return 0.0;

        auto halfTransposedCount = 0;
        auto k = 0;
        for (auto i = 0; i < a.length; ++i)
        {
            if (!matchesA[i]) continue;

            while (!matchesB[k]) ++k;

            if (a[i] != b[k]) ++halfTransposedCount;

            ++k;
        }

        const commonCountD = commonCount.to!double;
        const weight = (commonCountD / a.length
                         + commonCountD / b.length
                         + (commonCount - (halfTransposedCount / 2)) / commonCountD) / 3.0;

        if (weight <= weightThreshold) return weight;

        const prefixLength = min(prefixThreshold, min(a.length, b.length));
        auto pos = 0;
        while (pos < prefixLength && a[pos] == b[pos]) ++pos;
        if (pos == 0) return weight;
        return weight + 0.1 * pos * (1.0 - weight);
    }

    unittest
    {
        assert(jwd("hello, world", "hello, world") == 1.0);
        assert(jwd("no", "similarity") == 0.0);
    }
}
