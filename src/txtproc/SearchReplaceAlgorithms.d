import std.conv : to;
import std.range : retro, stride;
import std.regex : matchAll, regex, replaceAll;
import std.string;
import std.typecons : Tuple, tuple;

import Algorithm;
import Algorithms;
import TextAlgo;

bool terminalHasColors()
{
    import std.process;
    return environment.get("ANSICON") !is null;
}

private enum int[string] ansiColors =
[
    "black"  : 30,
    "red"    : 31,
    "green"  : 32,
    "yellow" : 33,
    "blue"   : 34,
    "magenta": 35,
    "cyan"   : 36,
    "white"  : 37,
];

private enum dchar[dchar] mirrorChars =
[
    '(' : ')',
    ')' : '(',
    '<' : '>',
    '>' : '<',
    '[' : ']',
    ']' : '[',
    '{' : '}',
    '}' : '{',
];

private static pure string mirror(string beginMarker)
{
    string endMarker;

    foreach (character; beginMarker.retro.stride(1))
    {
        auto c = (character in mirrorChars);

        if (c !is null)
        {
            endMarker ~= *c;
        }
        else
        {
            endMarker ~= character;
        }
    }

    return endMarker;
}

unittest
{
    assert(mirror("(") == ")");
    assert(mirror("))") == "((");
    assert(mirror("<") == ">");
    assert(mirror("<<<") == ">>>");
    assert(mirror("{") == "}");
    assert(mirror("(<}]") == "[{>)");
    assert(mirror("|") == "|");
    assert(mirror("abc") == "cba");
}

class SearchReplaceAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "Search", "Search & Replace", "Search sub-text in input text.", [
                ParameterDescription("The sub-text to search within the input text"),
                ParameterDescription("The marker used to indicate a find", Default(defaultMarker))],
            (string text, string[] params, bool ignoreCase) {
                return searchAndReplace(text, replaceSpecialChars(params[0]), null, ignoreCase, marker(params, 1));
            }
        ));

        add(new Algorithm(
            "Replace", "Search & Replace", "Replace sub-text in input text by a replacement text.", [
                ParameterDescription("The sub-text to replace"),
                ParameterDescription("The replacement text"),
                ParameterDescription("The marker used to indicate a replacement", Default(defaultMarker))],
            (string text, string[] params, bool ignoreCase) {
                return searchAndReplace(text, replaceSpecialChars(params[0]), replaceSpecialChars(params[1]), ignoreCase, marker(params, 2));
            }
        ));

        add(new Algorithm(
            "SearchRegex", "Search & Replace", "Search sub-text in input text using a regular expression.", [
                ParameterDescription("The regular expression to search within the input text"),
                ParameterDescription("The marker used to indicate a find", Default(defaultMarker))],
            (string text, string[] params, bool ignoreCase) {
                return searchAndReplaceRegex(text, replaceSpecialChars(params[0]), null, ignoreCase, marker(params, 1));
            }
        ));

        add(new Algorithm(
            "ReplaceRegex", "Search & Replace", "Replace sub-text in input text by a replacement text using a regular expression.", [
                ParameterDescription("The regular expression to replace"),
                ParameterDescription("The replacement text"),
                ParameterDescription("The marker used to indicate a replacement", Default(defaultMarker))],
            (string text, string[] params, bool ignoreCase) {
                return searchAndReplaceRegex(text, replaceSpecialChars(params[0]), replaceSpecialChars(params[1]), ignoreCase, marker(params, 2));
            }
        ));

        add(new Algorithm(
            "SearchNonAscii", "Search & Replace", "Search for non ASCII characters in input text.", [
                ParameterDescription("The marker used to indicate a replacement", Default(defaultMarker))],
            (string text, string[] params, bool ignoreCase) {
                return text.replaceAll(regex(r"([^\u0000-\u007F])"), marker(params, 0)("$1"));
            }
        ));

        add(new Algorithm(
            "SearchDuplicateWords", "Search & Replace", "Search the input text for consecutive words which have been duplicated.", [
                ParameterDescription("The marker used to indicate a duplication", Default(defaultMarker))],
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
                            result ~= marker(params, 0)(token.value);
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
    alias Marker = string delegate(string);

    enum defaultMarkerColor = "green";
    enum defaultMarkerText = ">>>";

    static string defaultMarker()
    {
        return terminalHasColors ? defaultMarkerColor : defaultMarkerText;
    }

    static Tuple!(string, string) beginEndMarker(string marker)
    {
        if (terminalHasColors && marker in ansiColors)
        {
            return tuple("\033[" ~ ansiColors[marker].text ~ "m", "\033[0m");
        }
        else
        {
            return tuple(marker, mirror(marker));
        }
    }

    static Marker marker(string[] params, size_t paramIndex)
    {
        immutable param = params.length > paramIndex ? params[paramIndex] : (terminalHasColors ? defaultMarkerColor : defaultMarkerText);
        immutable markers = beginEndMarker(param);
        return (text) => markers[0] ~ text ~ markers[1];
    }

    static string replaceSpecialChars(string text)
    {
       return text;
    }

    static string searchAndReplace(
        string input,
        string searchTerm,
        string replacementText,
        bool ignoreCase,
        Marker mark)
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
                result ~= mark(replacementText);
            }
            else
            {
                result ~= mark(input[finds[index] .. finds[index] + searchTerm.length]);
            }

            from = finds[index] + searchTerm.length;
        }

        result ~= input[from .. $];

        return result;
    }

    static string searchAndReplaceRegex(
        string input,
        string searchTerm,
        string replacementText,
        bool ignoreCase,
        Marker mark)
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

                result ~= mark(substReplacementText.text);
            }
            else
            {
                result ~= mark(match.front);
            }

            from = index + match.front.length;
        }

        result ~= input[from .. $];

        return result;
    }
}
