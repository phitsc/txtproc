module txtprocmain;

import std.getopt;

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

string txtproc_main(string[] args)
{
    import debugflag;

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

    version(Windows)
    {
        immutable winOnlyOpts = `
        "from-clipboard|v", "Read text to process from clipboard",                                           &fromClipboard,
        "to-clipboard|x",   "Write processed text to clipboard",                                             &toClipboard,      `;
    }
    else
    {
        immutable winOnlyOpts = "";
    }

    immutable getOpts = `getopt(args,
        "changes",          "Print change history",                                                          &printChanges,
        "execute|e",        "Function to process the supplied text with",                                    &functionName,
        "file|f",           "Input file containing text to process",                                         &inputFile,
        "ignore-case|i",    "Ignore case",                                                                   &ignoreCase,
        "list|l",           "List available text processing functions",                                      &listFunctions,
        "modify|m",         "Modify the input file in-place",                                                &modifyInputFile,
        "parameter|p",      "Parameter to pass to processing function. Supply multiple times if necessary.", &params,
        ` ~ winOnlyOpts ~ `
        "version",          "Print version information",                                                     &printVersionInfo,
        "debug|d",          "Print debug output",                                                            &printDebugOutput  )`;

    auto options = mixin(getOpts);

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
        return "txtproc version " ~ vers.text;
    }
    else if (printChanges)
    {
        return changes;
    }
    else if (options.helpWanted && functionName.empty)
    {
        import std.array : appender;
        auto output = appender!string();

        output.defaultGetoptFormatter("Usage: txtproc [options] [input text]", options.options);

        return output.data;
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
        return helpOnFunction(algorithms, functionName);
    }
    else if (listFunctions)
    {
        return functionList(algorithms, functionName);
    }

    const func = !functionName.empty ? algorithms.closest(functionName)[0] : new Algorithm("", "", "", [], (string text, string[], bool) => text);
    const outputText = func.process(getInputText(inputFile, fromClipboard, args), params, ignoreCase);

    if (modifyInputFile)
    {
        std.stdio.File(inputFile, "w").rawWrite(outputText);
        return "";
    }
    else if (toClipboard)
    {
        writeToClipboard(outputText);
        return "";
    }
    else
    {
        return outputText;
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
    import std.file : read;

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

private string functionList(const Algorithms algorithms, string filter)
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

    return result;
}

private string helpOnFunction(const Algorithms algorithms, string filter)
{
    return algorithms.closest(filter)[0].help;
}


unittest
{
    assert(txtproc_main(["txtproc", "--version"]).matchFirst(regex(`txtproc version \d+\.\d+\.\d+`)));
}
