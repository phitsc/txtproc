module txtprocmain;

import io;

import std.file : read;
import std.getopt;
import std.typecons : Tuple;

import txtproc.algorithms;
import txtproc.capitalisation_algorithms;
import txtproc.checksum_algorithms;
import txtproc.count_algorithms;
import txtproc.lines_algorithms;
import txtproc.order_algorithms;
import txtproc.searchreplace_algorithms;
import txtproc.sort_algorithms;
import txtproc.web_algorithms;

extern(C) int isatty(int);

private alias Option = Tuple!(string, "cmd", string, "desc");

private immutable Option[string] opts;

static this()
{
    opts =
    [
        "changes"       : Option("changes",          "Print change history"),
        "execute"       : Option("execute|e",        "Function to process the supplied text with"),
        "file"          : Option("file|f",           "Input file containing text to process"),
        "ignore-case"   : Option("ignore-case|i",    "Ignore case"),
        "list"          : Option("list|l",           "List available text processing functions"),
        "modify"        : Option("modify|m",         "Modify the input file in-place"),
        "parameter"     : Option("parameter|p",      "Parameter to pass to processing function. Supply multiple times if necessary."),
        "from-clipboard": Option("from-clipboard|v", "Read text to process from clipboard"),
        "to-clipboard"  : Option("to-clipboard|x",   "Write processed text to clipboard"),
        "version"       : Option("version",          "Print version information"),
        "debug"         : Option("debug|d",          "Print debug output"),
    ];
}

int txtproc_main(string[] args, string* result = null)
{
    import debugflag;

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
        bool printChanges;

        version(Windows) auto options = getopt(args,
            opts["changes"       ].cmd, opts["changes"       ].desc, &printChanges,
            opts["execute"       ].cmd, opts["execute"       ].desc, &functionName,
            opts["file"          ].cmd, opts["file"          ].desc, &inputFile,
            opts["ignore-case"   ].cmd, opts["ignore-case"   ].desc, &ignoreCase,
            opts["list"          ].cmd, opts["list"          ].desc, &listFunctions,
            opts["modify"        ].cmd, opts["modify"        ].desc, &modifyInputFile,
            opts["parameter"     ].cmd, opts["parameter"     ].desc, &params,
            opts["from-clipboard"].cmd, opts["from-clipboard"].desc, &fromClipboard,
            opts["to-clipboard"  ].cmd, opts["to-clipboard"  ].desc, &toClipboard,
            opts["version"       ].cmd, opts["version"       ].desc, &printVersionInfo,
            opts["debug"         ].cmd, opts["debug"         ].desc, &printDebugOutput
        );

        version(linux) auto options = getopt(args,
            opts["changes"       ].cmd, opts["changes"       ].desc, &printChanges,
            opts["execute"       ].cmd, opts["execute"       ].desc, &functionName,
            opts["file"          ].cmd, opts["file"          ].desc, &inputFile,
            opts["ignore-case"   ].cmd, opts["ignore-case"   ].desc, &ignoreCase,
            opts["list"          ].cmd, opts["list"          ].desc, &listFunctions,
            opts["modify"        ].cmd, opts["modify"        ].desc, &modifyInputFile,
            opts["parameter"     ].cmd, opts["parameter"     ].desc, &params,
            opts["version"       ].cmd, opts["version"       ].desc, &printVersionInfo,
            opts["debug"         ].cmd, opts["debug"         ].desc, &printDebugOutput
        );

        debug
        {
            immutable changes = "";
            immutable vers = "0.0.0";
        }
        else
        {
            immutable changes = import("CHANGES.txt");
            immutable vers = changes.matchFirst(regex(`v(\d+\.\d+\.\d+)`))[1];
        }

        if (printVersionInfo)
        {
            writeline("txtproc version " ~ vers.text);

            return 0;
        }
        else if (printChanges)
        {
            writeline(changes);

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
            std.stdio.File(inputFile, "w").rawWrite(outputText);
        }
        else if (toClipboard)
        {
            writeToClipboard(outputText);
        }
        else
        {
            writeline(outputText);
        }

        return 0;
    }
    catch (Exception e)
    {
        import std.stdio : stderr;

        stderr.rawWrite("Error: " ~ e.msg ~ "\n");

        if (printDebugOutput)
        {
            stderr.rawWrite(e.file.text ~ "(" ~ e.line.text ~ ")\n");
            stderr.rawWrite(e.info.text ~ "\n");
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
        return std.stdio.stdin.byLineCopy.array.join(newline);
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

    writeline(result);
}

private void printHelpOnFunction(const Algorithms algorithms, string filter)
{
    string result;

    auto algorithm = algorithms.closest(filter)[0];

    writeline(algorithm.help);
}

