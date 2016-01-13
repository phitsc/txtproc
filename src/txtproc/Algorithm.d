module txtproc.algorithm;

import std.ascii : newline;
import std.array : empty;
import std.algorithm : count;
import std.string : format;
import std.typecons : Nullable;

alias Default = Nullable!string;

struct ParameterDescription
{
    static Default noDefaultValue;

    this(string description, Default defaultValue = noDefaultValue)
    {
        m_description = description;
        m_defaultValue = defaultValue;
    }

    auto description() const
    {
        return m_description;
    }

    auto defaultValue() const
    {
        return m_defaultValue;
    }

    auto isMandatory() const
    {
        return m_defaultValue.isNull;
    }

private:
    string m_description;
    Nullable!string m_defaultValue;
}

alias ParameterDescriptions = ParameterDescription[];

class Algorithm
{
    alias Process = string delegate(string, string[], bool);

    this(string name, string group, string description, immutable ParameterDescriptions parameterDescriptions, Process process)
    {
        m_name                  = name;
        m_group                 = group;
        m_description           = description;
        m_parameterDescriptions = parameterDescriptions;
        m_process               = process;
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

    const(ParameterDescriptions) parameterDescriptions() const
    {
        return m_parameterDescriptions;
    }

    string help() const
    {
        auto text = m_name ~ " - " ~ m_description;

        if (!m_parameterDescriptions.empty)
        {
            text ~= newline ~ "  Parameters:";

            foreach (size_t index, ParameterDescription desc; m_parameterDescriptions)
            {
                text ~= newline ~ format("  %s. %s", (index + 1), desc.description);

                if (!desc.isMandatory)
                {
                    text ~= format(" (default: %s)", desc.defaultValue);
                }
            }
        }

        return text;
    }

    string process(string text, string[] params, bool ignoreCase) const
    {
        checkParams(params);

        for (size_t index = params.length; index < m_parameterDescriptions.length; ++index)
        {
            if (params.length < m_parameterDescriptions.length)
            {
                params ~= m_parameterDescriptions[index].defaultValue;
            }
        }

        return m_process(text, params, ignoreCase);
    }

    override bool opEquals(Object o) const
    {
        if(auto a = cast(Algorithm) o)
        {
            // Return true if both refer to the same instance.
            if(a is this)
            {
                return true;
            }

            return a.name == m_name;
        }

        return false;
    }

private:
    void checkParams(const(string[]) params) const
    {
        immutable requiredCount = m_parameterDescriptions.count!(a => a.isMandatory == true);
        if (params.length < requiredCount)
        {
            throw new Exception(format("Missing parameter(s). %s provided, %s required.", params.length, requiredCount));
        }
    }

private:
    immutable string  m_name;
    immutable string  m_group;
    immutable string  m_description;
    immutable ParameterDescriptions m_parameterDescriptions;
    immutable Process m_process;
}

unittest
{
    import std.exception;

    auto a = new Algorithm("Name", "Group", "Description of Name", [
            ParameterDescription("Parameter One"),
            ParameterDescription("Parameter One", Default("Default value")),
        ],
        (string text, string[] params, bool ignoreCase) {
            return text ~ params[0];
        }
    );

    assert(a.name == "Name");
    assert(a.group == "Group");
    assert(a.description == "Description of Name");
    assert(a.process("Input text ", [ "Param" ], false) == "Input text Param");
    assert(a.parameterDescriptions[0].description == "Parameter One");

    assert(a == a);
    auto b = a;
    assert(b == a);

    assertThrown(a.process("Input text", [], false));
}
