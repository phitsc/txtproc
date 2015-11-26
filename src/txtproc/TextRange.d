import std.algorithm;
import std.range;

import std.stdio;

enum string sentenceSeparatorChars = ".!?";
enum string bracketChars           = "[](){}<>";
enum string quoteChars             = "\"'";
enum string otherPunctuationChars  = ":+-/,;=%&*@#";
enum string wordSeparatorChars     = " \t\n\r" ~ sentenceSeparatorChars ~ bracketChars ~ "\"" ~ otherPunctuationChars;
enum string whitespaceChars        = " \t";

struct WordRange
{
    this(InputRangeObject!string text)
    {
        m_range = text;
        writeln(m_range);
    }

    @property bool empty()
    {
        return m_range.empty;
    }

    @property string front()
    {
        string word;

        foreach (character; m_range.stride(1))
        {
                writeln(character);

            if (wordSeparatorChars.canFind(character))
            {
                writeln(word);

                return word;
            }
            else
            {
                word ~= character;
            }
        }

                writeln(word);

        return word;
    }

    void popFront()
    {
    }

private:
    InputRangeObject!string m_range;
}

static WordRange words(string text)
{
    return WordRange(text.inputRangeObject);
}
