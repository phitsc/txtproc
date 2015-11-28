import std.algorithm;
import std.conv;
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
enum string wordSeparatorChars     = bracketChars ~ "\"" ~ otherPunctuationChars;
enum string whitespaceChars        = " \t";
enum string newlineChars           = "\r\n";


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

auto counts(string input)
{
    auto c = Tuple!(size_t, "alphaNumeric", size_t, "character", size_t, "white", size_t, "word", size_t, "sentence", size_t, "line")();
    c.line = 1;

    foreach (token; input.parseText)
    {
        if (token.type == TokenType.text)
        {
            c.alphaNumeric += token.value.count!(a => a.isAlpha || a.isNumber);
        }
        else if (token.type == TokenType.whitespace)
        {
            c.white += token.value.length;
            c.word += 1;
        }
        else if (token.type == TokenType.newline)
        {
            c.line += token.value.replace("\r\n", "\n").length;
            c.word += 1;
        }
        else if (token.type == TokenType.wordSeparator)
        {
            c.word += 1;
        }
        else if (token.type == TokenType.sentenceTerminator)
        {
            c.sentence += 1;
            c.word += 1;
        }

        c.character += token.value.replace("\r\n", "\n").walkLength;
    }

    return c;
}

enum TokenType
{
    none,
    text,
    whitespace,
    newline,
    wordSeparator,
    sentenceTerminator
}

alias TokenValue = string;
alias Token = Tuple!(TokenType, "type", TokenValue, "value");
alias Tokens = Token[];

Tokens parseText(string text)
{
    Tokens tokens;

    TokenType currentTokenType;
    TokenType newTokenType;
    string token;

    foreach (character; text.stride(1))
    {
        if (character == 0xFEFF || character.isNonCharacter || character.isMark)
        {
            continue;
        }
        else if (whitespaceChars.canFind(character))
        {
            newTokenType = TokenType.whitespace;
        }
        else if (newlineChars.canFind(character))
        {
            newTokenType = TokenType.newline;
        }
        else if (wordSeparatorChars.canFind(character))
        {
            newTokenType = TokenType.wordSeparator;
        }
        else if (sentenceSeparatorChars.canFind(character))
        {
            newTokenType = TokenType.sentenceTerminator;
        }
        else
        {
            newTokenType = TokenType.text;
        }

        if (newTokenType != currentTokenType)
        {
            if (currentTokenType != TokenType.none)
            {
                tokens ~= Token(currentTokenType, token);
            }

            token = format("%s", character);
            currentTokenType = newTokenType;
        }
        else
        {
            token ~= character;
        }
    }

    tokens ~= Token(currentTokenType, token);

    return tokens;
}

alias lines = elements!(TokenType.newline);
alias sentences = elements!(TokenType.sentenceTerminator);

Tokens[] elements(alias tokenType)(Tokens tokens)
{
    Tokens[] result;

    Tokens current;

    foreach (token; tokens)
    {
        current ~= token;

        if (token.type == tokenType)
        {
            result ~= current;
            current = [];
        }
    }

    if (!current.empty)
    {
        result ~= current;
    }

    return result;
}

string reverseUni(string text)
{
    return text.byGrapheme.array.retro.byCodePoint.text;
}
