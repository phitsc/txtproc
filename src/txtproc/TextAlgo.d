import std.algorithm;
import std.range;
import std.string;
import std.typecons;
import std.uni;

import std.stdio;

enum string sentenceSeparatorChars = ".!?";
enum string bracketChars           = "[](){}<>";
enum string quoteChars             = "\"'";
enum string otherPunctuationChars  = ":+-/,;=%&*@#";
enum string lineSeparatorChars     = "\n\r";
enum string wordSeparatorChars     = " \t" ~ lineSeparatorChars ~ sentenceSeparatorChars ~ bracketChars ~ "\"" ~ otherPunctuationChars;
enum string whitespaceChars        = " \t";


alias eachWord = eachTextElement!wordSeparatorChars;
alias eachSentence = eachTextElement!sentenceSeparatorChars;

auto eachTextElement(alias separators)(string input, string function(string) func)
{
    string result;
    string element;

    foreach (character; input.stride(1))
    {
        if (separators.canFind(character))
        {
            result ~= func(element);
            result ~= character;
            element = "";
        }
        else
        {
            element ~= character;
        }
    }

    result ~= func(element);

    return result;
}

auto splitTextElements(alias separators)(string input, KeepTerminator keepTerminator = KeepTerminator.no)
{
    string[] result;
    string element;
    bool foundSeparator;

    foreach (character; input.stride(1))
    {
        if (separators.canFind(character))
        {
            if (!foundSeparator && !keepTerminator)
            {
                result ~= element;
                element = format("%s", character);
            }
            else
            {
                element ~= character;
            }

            foundSeparator = true;
        }
        else if (foundSeparator)
        {
            result ~= element;
            element = format("%s", character);

            foundSeparator = false;
        }
        else
        {
            element ~= character;
        }
    }

    result ~= element;

    return result;
}

auto counts(string input)
{
    auto c = Tuple!(size_t, "alphaNumeric", size_t, "character", size_t, "white", size_t, "word", size_t, "sentence", size_t, "line")();
    c.line = 1;
    bool inWord;
    bool inSentence;
    bool inBackslashR;

    foreach (character; input.stride(1))
    {
        if (character == 0xFEFF ||character.isNonCharacter || character.isMark)
        {
            continue;
        }

        if (character.isAlpha || character.isNumber)
        {
            c.alphaNumeric++;

            if (!inWord)
            {
                c.word++;
            }

            if (!inSentence)
            {
                c.sentence++;
            }

            inWord = true;
            inSentence = true;
        }
        else if (wordSeparatorChars.canFind(character))
        {
            inWord = false;

            if (whitespaceChars.canFind(character))
            {
                c.white++;
            }
            else if (character == '\r')
            {
                c.line++;

                inBackslashR = true;
            }
            else if (character == '\n')
            {
                if (!inBackslashR)
                {
                    c.line++;
                }
                else
                {
                    c.character--; // count' \r\n as one character
                }

                inBackslashR = false;
            }
            else if (sentenceSeparatorChars.canFind(character))
            {
                inSentence = false;
            }
        }

        c.character++;

        //writeln(format("%s (%d): %s", character, character, c.character));
    }

    return c;
}
