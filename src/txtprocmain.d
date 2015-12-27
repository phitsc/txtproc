import std.file : read;
import std.getopt;
import std.stdio;

import Algorithm;
import CapitalisationAlgorithms;
import ChecksumAlgorithms;
import CountAlgorithms;
import LinesAlgorithms;
import OrderAlgorithms;
import SearchReplaceAlgorithms;
import SortAlgorithms;
import WebAlgorithms;

extern(C) int isatty(int);

int txtproc_main(string[] args, string* result = null)
{
    bool printDebugOutput;

    try
    {
        string functionName;
        string inputFile;
        bool ignoreCase;
        bool listFunctions;
        bool modifyInputFile;
        string[] params;
        bool fromClipboard;
        bool toClipboard;
        bool printVersionInfo;

        immutable opts =
        [
            [ "execute|e",        "Function to process the supplied text with" ],
            [ "file|f",           "Input file containing text to process" ],
            [ "ignore-case|i",    "Ignore case"],
            [ "list|l",           "List available text processing functions" ],
            [ "modify|m",         "Modify the input file in-place" ],
            [ "parameter|p",      "Parameter to pass to processing function. Supply multiple times if necessary." ],
            [ "from-clipboard|v", "Read text to process from clipboard" ],
            [ "to-clipboard|x",   "Write processed text to clipboard" ],
            [ "version",          "Print version information"],
            [ "debug|d",          "Print debug output"]
        ];

        version(Windows) auto options = getopt(args,
            opts[0][0], opts[0][1], &functionName,
            opts[1][0], opts[1][1], &inputFile,
            opts[2][0], opts[2][1], &ignoreCase,
            opts[3][0], opts[3][1], &listFunctions,
            opts[4][0], opts[4][1], &modifyInputFile,
            opts[5][0], opts[5][1], &params,
            opts[6][0], opts[6][1], &fromClipboard,
            opts[7][0], opts[7][1], &toClipboard,
            opts[8][0], opts[8][1], &printVersionInfo,
            opts[9][0], opts[9][1], &printDebugOutput
        );

        version(linux) auto options = getopt(args,
            opts[0][0], opts[0][1], &functionName,
            opts[1][0], opts[1][1], &inputFile,
            opts[2][0], opts[2][1], &ignoreCase,
            opts[3][0], opts[3][1], &listFunctions,
            opts[4][0], opts[4][1], &modifyInputFile,
            opts[5][0], opts[5][1], &params,
            opts[8][0], opts[8][1], &printVersionInfo,
            opts[9][0], opts[9][1], &printDebugOutput
        );

        if (printVersionInfo)
        {
            writeln("txtproc version 0.3.0");

            return 0;
        }
        else if (options.helpWanted && functionName.empty)
        {
            defaultGetoptPrinter("Usage: txtproc [options] [input text]", options.options);

            return 0;
        }

        auto algorithms = new Algorithms;
        algorithms.add(new CapitalisationAlgorithms);
        algorithms.add(new ChecksumAlgorithms);
        algorithms.add(new CountAlgorithms);
        algorithms.add(new LinesAlgorithms);
        algorithms.add(new OrderAlgorithms);
        algorithms.add(new SearchReplaceAlgorithms);
        algorithms.add(new SortAlgorithms);
        algorithms.add(new WebAlgorithms);

        if (options.helpWanted)
        {
            printHelpOnFunction(algorithms, functionName);

            return 0;
        }
        else if (listFunctions)
        {
            printFunctionList(algorithms, functionName);

            return 0;
        }

        const func = !functionName.empty ? algorithms.closest(functionName)[0] : new Algorithm("", "", "", [], (string text, string[], bool) => text);
        const outputText = func.process(getInputText(inputFile, fromClipboard, args), params, ignoreCase);

        if (result)
        {
            *result = outputText;
        }
        else if (modifyInputFile)
        {
            File(inputFile, "w").rawWrite(outputText);
        }
        else if (toClipboard)
        {
            writeToClipboard(outputText);
        }
        else
        {
            stdout.rawWrite(outputText ~ "\n");
        }

        return 0;
    }
    catch (Exception e)
    {
        stderr.writeln("Error: ", e.msg);

        if (printDebugOutput)
        {
            stderr.writeln(e.file, "(", e.line, ")");
            stderr.writeln(e.info);
        }

        return 1;
    }
}

version(Windows)
{
    import core.sys.windows.windows;

    extern(Windows)
    {
        BOOL OpenClipboard(HWND);
        BOOL CloseClipboard();
        BOOL EmptyClipboard();

        HANDLE  GetClipboardData(UINT);
        HANDLE  SetClipboardData(UINT, HANDLE);
        HGLOBAL GlobalAlloc(UINT, size_t);
        HGLOBAL GlobalLock(HGLOBAL);
        BOOL    GlobalUnlock(HGLOBAL);
    }

    extern(C) size_t wcslen(const wchar*);
    extern(C) void* memcpy(void*, const void*, size_t);

    enum CF_UNICODETEXT = 13;

    private string readFromClipboard()
    {
        string result;

        if (OpenClipboard(null))
        {
            scope (exit) CloseClipboard();

            if (void* handle = GetClipboardData(CF_UNICODETEXT))
            {
                if (wchar* wstr = cast(wchar*)GlobalLock(handle))
                {
                    result = to!string(wstr[0..wcslen(wstr)]);

                    GlobalUnlock(wstr);
                }
            }
        }

        return result;
    }

    private void writeToClipboard(string text)
    {
        if (OpenClipboard(null))
        {
            scope (exit) CloseClipboard();

            immutable length = (text.length + 1) * wchar.sizeof;
            if (void* handle = GlobalAlloc(2, length))
            {
                if (void* ptr = GlobalLock(handle))
                {
                    EmptyClipboard();

                    memcpy(ptr, cast(wchar*)to!wstring(text), length);
                    GlobalUnlock(handle);

                    SetClipboardData(CF_UNICODETEXT, handle);
                }
            }
        }
    }
}

version(linux)
{
    private string readFromClipboard()
    {
        return "";
    }

    private void writeToClipboard(string text)
    {
    }
}

private bool isUtf8(void[] rawText)
{
    import std.utf;

    try
    {
        validate!string(cast(string) rawText);

        return true;
    }
    catch (UTFException)
    {
        return false;
    }
}

private bool isUtf16(void[] rawText)
{
    import std.utf;

    try
    {
        validate!wstring(cast(wstring) rawText);

        return true;
    }
    catch (UTFException)
    {
        return false;
    }
}

private string toUtf(S)(void[] rawText)
{
    import std.encoding;

    string text;
    transcode(cast(S) rawText, text);

    return text;
}

private string readFromFile(string path)
{
    import std.encoding;

    auto rawFileContents = read(path);

    if (isUtf8(rawFileContents))
    {
        return toUtf!string(rawFileContents);
    }
    else if (isUtf16(rawFileContents))
    {
        return toUtf!wstring(rawFileContents);
    }
    else
    {
        throw new Exception("Don't know how to deal with encoding of " ~ path);
    }
}

private string getInputText(string inputFile, bool fromClipboard, string[] args)
{
    if (!isatty(0))
    {
        return stdin.byLineCopy.array.join(newline);
    }
    else if (fromClipboard)
    {
       return readFromClipboard();
    }
    else if (!inputFile.empty)
    {
        return readFromFile(inputFile);
    }
    else
    {
        return args[1..$].join(" ");
    }
}

private void printFunctionList(const Algorithms algorithms, string filter)
{
    string result;

    size_t maxAlgorithmWidth;

    foreach (algorithm; algorithms)
    {
        maxAlgorithmWidth = max(maxAlgorithmWidth, algorithm.name.length);
    }

    auto algos = filter.empty ? algorithms.all() : algorithms.closest(filter);

    foreach (algorithm; algos)
    {
        if (!result.empty)
        {
            result ~= std.ascii.newline;
        }

        result ~= leftJustify(algorithm.name, maxAlgorithmWidth, ' ') ~ " - " ~ algorithm.description;
    }

    stdout.rawWrite(result ~ "\n");
}

private void printHelpOnFunction(const Algorithms algorithms, string filter)
{
    string result;

    auto algorithm = algorithms.closest(filter)[0];

    writeln(algorithm.help);
}

