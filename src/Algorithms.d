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

    Algorithm find(string nameish)
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

    string toString(string filter)
    {
        string result;

        foreach (algorithm; m_algorithms)
        {
            if (filter == "*" || algorithm.name.indexOf(filter, CaseSensitive.no) != -1)
            {
                result ~= algorithm.name ~ std.ascii.newline;
            }
        }

        return result;
    }

protected:
    void add(Algorithm algorithm)
    {
        m_algorithms ~= algorithm;
    }

private:
    Algorithm[] m_algorithms;
}
