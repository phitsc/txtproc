import std.algorithm : canFind, map, countIf = count;
import std.conv : text;
import std.range;
import std.traits;
import std.typecons;
import std.uni;

import std.stdio;

private enum string sentenceSeparatorChars = ".!?";
private enum string bracketChars           = "[](){}<>";
private enum string quoteChars             = "\"'";
private enum string otherPunctuationChars  = ":+-/,;=%&*@#";
private enum string wordTerminatorChars    = bracketChars ~ "\"" ~ otherPunctuationChars;
private enum string whitespaceChars        = " \t";
private enum string lineTerminatorChars    = "\r\n";

pure auto count(string input)
{
    auto c = Tuple!(size_t, "alphaNumerics", size_t, "characters", size_t, "whitespaces", size_t, "words", size_t, "sentences", size_t, "lines")();
    c.lines = 1;

    foreach (token; input.parseText)
    {
        if (token.type == TokenType.text)
        {
            c.alphaNumerics += token.value.countIf!(a => a.isAlpha || a.isNumber);
            c.words += 1;
        }
        else if (token.type == TokenType.whitespace)
        {
            c.whitespaces += token.value.length;
        }
        else if (token.type == TokenType.lineTerminator)
        {
            c.lines += token.value.replace("\r\n", "\n").length;
        }
        else if (token.type == TokenType.sentenceTerminator)
        {
            c.sentences += 1;
        }

        c.characters += token.value.replace("\r\n", "\n").walkLength;
    }

    return c;
}

enum TokenType
{
    none,
    text,
    whitespace,
    lineTerminator,
    wordTerminator,
    sentenceTerminator
}

alias TokenValue = string;
alias Token = Tuple!(TokenType, "type", TokenValue, "value");
alias Tokens = Token[];

pure auto parseText(string text)
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
        else if (lineTerminatorChars.canFind(character))
        {
            newTokenType = TokenType.lineTerminator;
        }
        else if (wordTerminatorChars.canFind(character))
        {
            newTokenType = TokenType.wordTerminator;
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

pure auto toText(T)(T tokens)
{
    return tokens.map!(a => a.value).join;
}

pure auto stripLeft(Tokens tokens)
{
    Tokens result;

    bool stripped = false;

    foreach (token; tokens)
    {
        if (stripped || token.type != TokenType.whitespace)
        {
            result ~= token;
        }
        else
        {
            stripped = true;
        }
    }

    return result;
}

alias lines = elements!(TokenType.lineTerminator);
alias sentences = elements!(TokenType.sentenceTerminator);

pure auto elements(alias tokenType)(Tokens tokens)
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
