import std.algorithm;
import std.array;
import std.conv;
import std.range;
import std.regex;
import std.string;
import std.uni;

import Algorithms;

class SearchReplaceAlgorithms : Algorithms
{
    this()
    {
        add(new Algorithm(
            "Search", "Search & Replace",
            (string text, string[] params, bool ignoreCase, bool) {
                if (params.length < 1)
                {
                    throw new Exception("Missing parameter (search text)");
                }

                return searchAndReplace(text, replaceSpecialChars(params[0]), stag(params, 1), etag(params, 2), null, ignoreCase);
            }
        ));

        add(new Algorithm(
            "Replace", "Search & Replace",
            (string text, string[] params, bool ignoreCase, bool) {
                if (params.length < 1)
                {
                    throw new Exception("Missing parameter (search text)");
                }
                else if (params.length < 2)
                {
                    throw new Exception("Missing parameter (replacement text)");
                }

                return searchAndReplace(text, replaceSpecialChars(params[0]), stag(params, 2), etag(params, 3), replaceSpecialChars(params[1]), ignoreCase);
            }
        ));

        add(new Algorithm(
            "RegexSearch", "Search & Replace",
            (string text, string[] params, bool ignoreCase, bool) {
                if (params.length < 1)
                {
                    throw new Exception("Missing parameter (search text)");
                }

                return searchAndReplaceRegex(text, replaceSpecialChars(params[0]), stag(params, 1), etag(params, 2), null, ignoreCase);
            }
        ));

        add(new Algorithm(
            "RegexReplace", "Search & Replace",
            (string text, string[] params, bool ignoreCase, bool) {
                if (params.length < 1)
                {
                    throw new Exception("Missing parameter (search text)");
                }
                else if (params.length < 2)
                {
                    throw new Exception("Missing parameter (replacement text)");
                }

                return searchAndReplaceRegex(text, replaceSpecialChars(params[0]), stag(params, 2), etag(params, 3), replaceSpecialChars(params[1]), ignoreCase);
            }
        ));

        add(new Algorithm(
            "SearchNonAscii", "Search & Replace",
            (string text, string[] params, bool ignoreCase, bool) {

                return text.replaceAll(regex(r"([^\u0000-\u007F])"), stag(params, 0) ~ "$1" ~ etag(params, 1));
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
