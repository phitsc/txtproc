import std.conv : to;
import std.range : stride;
import std.regex : matchAll, regex, replaceAll;
import std.string;

import Algorithm;
import Algorithms;
import TextAlgo;

class SearchReplaceAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "Search", "Search & Replace", "Search sub-text in input text.", [
                ParameterDescription("The sub-text to search within the input text"),
                ParameterDescription("The start tag used to indicate a find", Default(defaultStag)),
                ParameterDescription("The end tag used to indicate a find", Default(defaultEtag))],
            (string text, string[] params, bool ignoreCase) {
                return searchAndReplace(text, replaceSpecialChars(params[0]), stag(params, 1), etag(params, 2), null, ignoreCase);
            }
        ));

        add(new Algorithm(
            "Replace", "Search & Replace", "Replace sub-text in input text by a replacement text.", [
                ParameterDescription("The sub-text to replace"),
                ParameterDescription("The replacement text"),
                ParameterDescription("The start tag used to indicate a replacement", Default(defaultStag)),
                ParameterDescription("The end tag used to indicate a replacement", Default(defaultEtag))],
            (string text, string[] params, bool ignoreCase) {
                return searchAndReplace(text, replaceSpecialChars(params[0]), stag(params, 2), etag(params, 3), replaceSpecialChars(params[1]), ignoreCase);
            }
        ));

        add(new Algorithm(
            "SearchRegex", "Search & Replace", "Search sub-text in input text using a regular expression.", [
                ParameterDescription("The regular expression to search within the input text"),
                ParameterDescription("The start tag used to indicate a replacement", Default(defaultStag)),
                ParameterDescription("The end tag used to indicate a replacement", Default(defaultEtag))],
            (string text, string[] params, bool ignoreCase) {
                return searchAndReplaceRegex(text, replaceSpecialChars(params[0]), stag(params, 1), etag(params, 2), null, ignoreCase);
            }
        ));

        add(new Algorithm(
            "ReplaceRegex", "Search & Replace", "Replace sub-text in input text by a replacement text using a regular expression.", [
                ParameterDescription("The regular expression to replace"),
                ParameterDescription("The replacement text"),
                ParameterDescription("The start tag used to indicate a replacement", Default(defaultStag)),
                ParameterDescription("The end tag used to indicate a replacement", Default(defaultEtag))],
            (string text, string[] params, bool ignoreCase) {
                return searchAndReplaceRegex(text, replaceSpecialChars(params[0]), stag(params, 2), etag(params, 3), replaceSpecialChars(params[1]), ignoreCase);
            }
        ));

        add(new Algorithm(
            "SearchNonAscii", "Search & Replace", "Search for non ASCII characters in input text.", [],
            (string text, string[] params, bool ignoreCase) {
                return text.replaceAll(regex(r"([^\u0000-\u007F])"), stag(params, 0) ~ "$1" ~ etag(params, 1));
            }
        ));

        add(new Algorithm(
            "SearchDuplicateWords", "Search & Replace", "Search the input text for consecutive words which have been duplicated.", [
                ParameterDescription("The start tag used to indicate a duplication", Default(defaultStag)),
                ParameterDescription("The end tag used to indicate a duplication", Default(defaultEtag))],
            (string text, string[] params, bool ignoreCase) {
                string result;

                string previousWord;

                foreach (token; text.parseText)
                {
                    if (token.type == TokenType.text)
                    {
                        if ((ignoreCase && !icmp(token.value, previousWord)) ||
                            (token.value == previousWord))
                        {
                            result ~= params[0] ~ token.value ~ params[1];
                        }
                        else
                        {
                            result ~= token.value;
                        }

                        previousWord = token.value;
                    }
                    else
                    {
                        result ~= token.value;
                    }
                }

                return result;
            }
        ));

        add(new Algorithm(
            "TabsToSpaces", "Search & Replace", "Replace tabs by spaces such that characters following a tab align at their respective tab stops.", [
                ParameterDescription("Distance between tab stops", Default("4")),
            ],
            (string text, string[] params, bool ignoreCase) {
                return text.detab(to!size_t(params[0]));
            }
        ));

        add(new Algorithm(
            "SpacesToTabs", "Search & Replace", "Replace spaces with the optimal number of tabs (spaces and tabs at the end of a line are removed).", [
                ParameterDescription("Distance between tab stops", Default("4")),
            ],
            (string text, string[] params, bool ignoreCase) {
                return text.entab(to!size_t(params[0])).to!string;
            }
        ));

        add(new Algorithm(
            "RemoveCharacters", "Search & Replace", "Removes the specified set of characters from the input text).", [
                ParameterDescription("Characters to remove"),
            ],
            (string text, string[] params, bool ignoreCase) {
                string result;

                foreach (character; text.stride(1))
                {
                    if (params[0].indexOf(character, ignoreCase ? CaseSensitive.no : CaseSensitive.yes) == -1)
                    {
                        result ~= character;
                    }
                }

                return result;
            }
        ));

        add(new Algorithm(
            "FlipUpsideDown", "Search & Replace", "Flips the input text upside down (works only for supported characters).", [],
            (string text, string[] params, bool ignoreCase) {
                immutable dchar[dchar] translationTable = [
                    'a': 'ɐ', 'b': 'q', 'c': 'ɔ', 'd': 'p', 'e': 'ǝ', 'f': 'ɟ', 'g': 'ƃ', 'h': 'ɥ', 'i': 'ᴉ', 'j': 'ɾ', 'k': 'ʞ', 'l': 'l', 'm': 'ɯ', 'n': 'u', 'o': 'o', 'p': 'd', 'q': 'b', 'r': 'ɹ', 's': 's', 't': 'ʇ', 'u': 'n', 'v': 'ʌ', 'w': 'ʍ', 'x': 'x', 'y': 'ʎ', 'z': 'z',
                    'A': 'Ɐ', 'B': 'B', 'C': 'Ɔ', 'D': 'D', 'E': 'Ǝ', 'F': 'Ⅎ', 'G': 'פ', 'H': 'H', 'I': 'I', 'J': 'ſ', 'K': 'K', 'L': '˥', 'M': 'Ɯ', 'N': 'N', 'O': 'O', 'P': 'Ԁ', 'Q': 'Q', 'R': 'R', 'S': 'S', 'T': '┴', 'U': '∩', 'V': 'Ʌ', 'W': 'M', 'X': 'X', 'Y': 'ʎ', 'Z': 'Z',
                    ',': '\'', '.': '˙', '?': '¿', '!': '¡', '\'': ',', '(': ')', ')': '(', '[': ']', ']': '[', '<': '>', '>': '<', '{': '}', '}': '{', '_': '‾'
                ];

                return text.translate(translationTable);
            }
        ));
    }

private:
    enum auto defaultStag = ">>>";
    enum auto defaultEtag = "<<<";

    static string stag(string[] params, size_t paramIndex)
    {
        immutable param = params.length > paramIndex ? params[paramIndex] : defaultStag;
        return param == r"\0" ? "" : param;
    }

    static string etag(string[] params, size_t paramIndex)
    {
        immutable param = params.length > (paramIndex - 1) ? (params.length > paramIndex ? params[paramIndex] : params[paramIndex - 1]) : defaultEtag;
        return param == r"\0" ? "" : param;
    }

    static string replaceSpecialChars(string text)
    {
       return text;
    }

    static string searchAndReplace(
        string input,
        string searchTerm,
        string searchStartTag,
        string searchEndTag,
        string replacementText,
        bool ignoreCase)
    {
        ptrdiff_t[] finds;

        auto pos = input.indexOf(searchTerm, ignoreCase ? CaseSensitive.no : CaseSensitive.yes);
        while ((pos != -1) && (pos < input.length) && !searchTerm.empty)
        {
            finds ~= pos;

            pos = input.indexOf(searchTerm, pos + 1, ignoreCase ? CaseSensitive.no : CaseSensitive.yes);
        }

        string result;

        size_t from = 0;
        for (size_t index = 0; index < finds.length; ++index)
        {
            result ~= input[from .. finds[index]];

            if (replacementText)
            {
                result ~= searchStartTag ~ replacementText ~ searchEndTag;
            }
            else
            {
                result ~= searchStartTag ~ input[finds[index] .. finds[index] + searchTerm.length] ~ searchEndTag;
            }

            from = finds[index] + searchTerm.length;
        }

        result ~= input[from .. $];

        return result;
    }

    static string searchAndReplaceRegex(
        string input,
        string searchTerm,
        string searchStartTag,
        string searchEndTag,
        string replacementText,
        bool ignoreCase)
    {
        string result;

        size_t from = 0;
        foreach (match; input.matchAll(regex(searchTerm, "m" ~ (ignoreCase ? "i" : ""))))
        {
            immutable index = match.pre.length;

            result ~= input[from .. index];

            if (replacementText)
            {
                auto substReplacementText = replacementText.dup;

                for (size_t captureIndex = 1; captureIndex < match.captures.length; ++captureIndex)
                {
                    substReplacementText = substReplacementText.replace("\\" ~ captureIndex.text, match.captures[captureIndex]);
                }

                result ~= searchStartTag ~ substReplacementText ~ searchEndTag;
            }
            else
            {
                result ~= searchStartTag ~ match.front ~ searchEndTag;
            }

            from = index + match.front.length;
        }

        result ~= input[from .. $];

        return result;
    }
}
