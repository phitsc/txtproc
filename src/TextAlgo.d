import std.algorithm;
import std.range;
import std.typecons;
import std.uni;

enum string sentenceSeparatorChars = ".!?";
enum string bracketChars           = "[](){}<>";
enum string quoteChars             = "\"'";
enum string otherPunctuationChars  = ":+-/,;=%&*@#";
enum string lineSeparatorChars     = "\n\r";
enum string wordSeparatorChars     = " \t" ~ lineSeparatorChars ~ sentenceSeparatorChars ~ bracketChars ~ "\"" ~ otherPunctuationChars;
enum string whitespaceChars        = " \t";

auto eachWord(string input, string function(string) func)
{
    string result;
    string word;

    foreach (character; input.stride(1))
    {
        if (wordSeparatorChars.canFind(character))
        {
            result ~= func(word);
            result ~= character;
            word = "";
        }
        else
        {
            word ~= character;
        }
    }

    result ~= func(word);

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
            inWord = false;;

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
    }

    return c;
}
