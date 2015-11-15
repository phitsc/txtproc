
class Algorithm
{
    alias Process = string function(string, string[], bool, bool);

    this(string name, string group, Process process)
    {
        m_name    = name;
        m_group   = group;
        m_process = process;
    }

    string name() @property const
    {
        return m_name;
    }

    string process(string text, string[] params, bool ignoreCase, bool reverseOutput)
    {
        return m_process(text, params, ignoreCase, reverseOutput);
    }

private:
    string  m_name;
    string  m_group;
    Process m_process;
}