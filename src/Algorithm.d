
class Algorithm
{
    alias Process = string function(string, string[], bool);

    this(string name, string group, string description, Process process)
    {
        m_name        = name;
        m_group       = group;
        m_description = description;
        m_process     = process;
    }

    string name() const
    {
        return m_name;
    }

    string group() const
    {
        return m_group;
    }

    string description() const
    {
        return m_description;
    }

    string process(string text, string[] params, bool ignoreCase) const
    {
        return m_process(text, params, ignoreCase);
    }

private:
    immutable string  m_name;
    immutable string  m_group;
    immutable string  m_description;
    immutable Process m_process;
}
