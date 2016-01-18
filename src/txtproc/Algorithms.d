module txtproc.algorithms;

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

    auto closest(string nameish) const
    {
        import std.algorithm : map, makeIndex;
        import std.array : array;
        import std.string : toLower;
        import std.typecons : tuple;

        const algorithmsByDistance = m_algorithms.map!(a => tuple(jwd(a.name.toLower, nameish.toLower), a)).array;

        auto indices = new size_t[algorithmsByDistance.length];

        algorithmsByDistance.makeIndex!((a, b) => a[0] > b[0])(indices);

        import debugflag;
        if (printDebugOutput)
        {
            import debugflag;
            import std.conv : text;
            import std.stdio : stdout;
            indices.map!(a => stdout.rawWrite(algorithmsByDistance[a][1].name ~ " : " ~ algorithmsByDistance[a][0].text ~ "\n"));
        }

        const(Algorithm)[] result;

        foreach (index; indices)
        {
            result ~= algorithmsByDistance[index][1];
        }

        return result;
    }

    auto all() const
    {
        return m_algorithms;
    }

protected:
    void add(const(Algorithm) algorithm)
    {
        import std.algorithm : canFind;

        assert(!m_algorithms.canFind(algorithm), "Algorithm names must be unique");

        m_algorithms ~= algorithm;
    }

private:
    const(Algorithm)[] m_algorithms;

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

        ptrdiff_t searchRange = max(0, max(a.length, b.length) / 2 - 1); // signed for use in min/max

        auto matchesA = new bool[a.length];
        auto matchesB = new bool[b.length];

        auto commonCount = 0;

        for (auto i = 0; i < a.length; ++i)
        {
            size_t start = max(0, i - searchRange);
            size_t end = min(i + searchRange + 1, b.length);

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
        assert(jwd("", "") == 1.0);
    }
}
