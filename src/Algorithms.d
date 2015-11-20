import std.array;
import std.string;

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

private:
    Algorithm[] m_algorithms;
}
