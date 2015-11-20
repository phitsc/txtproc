
class Algorithm
{
    alias Process = string function(string, string[], bool, bool);

    this(string name, string group, Process process)
    {
        m_name    = name;
        m_group   = group;
        m_process = process;
    }

    string name() const
    {
        return m_name;
    }

    string process(string text, string[] params, bool ignoreCase, bool reverseOutput) const
    {
        return m_process(text, params, ignoreCase, reverseOutput);
    }

private:
    immutable string  m_name;
    immutable string  m_group;
    immutable Process m_process;
}
