import std.algorithm;
import std.array;
import std.file;
import std.getopt;
import std.range;
import std.stdio;
import std.string;

import Algorithm;
import CountAlgorithms;
import CapitalisationAlgorithms;
import OrderAlgorithms;
import SearchReplaceAlgorithms;

extern(C) int isatty(int);

int main(string[] args)
{
    try
    {
        bool ignoreCase;
        string functionName;
        string inputFile;
        bool listFunctions;
        bool modifyInputFile;
        string[] params;
        bool fromClipboard;
        bool toClipboard;

        immutable opts =
        [
            [ "ignore-case|c", "Ignore case."],
            [ "function|f", "Function to process the supplied text with." ],
            [ "input-file|i", "Input file containing text to process." ],
            [ "list-functions|l", "List available text processing functions." ],
            [ "modify-input-file|m", "Modify the input file in-place." ],
            [ "parameter|p", "Parameter to pass to processing function. Supply multiple times if necessary." ],
            [ "from-clipboard|v", "Read text to process from clipboard" ],
            [ "to-clipboard|x", "Write processed text to clipboard" ]
        ];

        version(Windows) auto options = getopt(args,
            opts[0][0], opts[0][1], &ignoreCase,
            opts[1][0], opts[1][1], &functionName,
            opts[2][0], opts[2][1], &inputFile,
            opts[3][0], opts[3][1], &listFunctions,
            opts[4][0], opts[4][1], &modifyInputFile,
            opts[5][0], opts[5][1], &params,
            opts[6][0], opts[6][1], &fromClipboard,
            opts[7][0], opts[7][1], &toClipboard
        );

        version(Linux) auto options = getopt(args,
            opts[0][0], opts[0][1], &ignoreCase,
            opts[1][0], opts[1][1], &functionName,
            opts[2][0], opts[2][1], &inputFile,
            opts[3][0], opts[3][1], &listFunctions,
            opts[4][0], opts[4][1], &modifyInputFile,
            opts[5][0], opts[5][1], &params
        );

        if (options.helpWanted && functionName.empty)
        {
            defaultGetoptPrinter("Usage: txtproc [options] [input text]", options.options);

            return 0;
        }

        auto algorithms = new Algorithms;
        algorithms.add(new CountAlgorithms);
        algorithms.add(new CapitalisationAlgorithms);
        algorithms.add(new OrderAlgorithms);
        algorithms.add(new SearchReplaceAlgorithms);

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

        const func = !functionName.empty ? algorithms.closest(functionName)[0] : new Algorithm("", "", "", (string text, string[], bool) => text);
        const outputText = func.process(getInputText(inputFile, fromClipboard, args), params, ignoreCase);

        if (modifyInputFile)
        {
            File(inputFile, "w").rawWrite(outputText);
        }
        else if (toClipboard)
        {
            writeToClipboard(outputText);
        }
        else
        {
            writeln(outputText);
        }

        return 0;
    }
    catch (Exception e)
    {
        writeln("Error: ", e.msg);

        return 1;
    }
}

version(Windows)
{
    extern(Windows)
    {
        bool OpenClipboard(void*);
        bool CloseClipboard();
        bool EmptyClipboard();

        void* GetClipboardData(uint);
        void* SetClipboardData(uint, void*);
        void* GlobalAlloc(uint, size_t);
        void* GlobalLock(void*);
        bool  GlobalUnlock(void*);
    }

    extern(C) size_t strlen(const char*);
    extern(C) void* memcpy(void*, const void*, size_t);

    string readFromClipboard()
    {
        if (OpenClipboard(null))
        {
            scope (exit) CloseClipboard();

            if (auto cstr = cast(char*)GetClipboardData(1))
            {
                return cstr[0..strlen(cstr)].idup;
            }
        }

        return "";
    }

    void writeToClipboard(string text)
    {
        if (OpenClipboard(null))
        {
            scope (exit) CloseClipboard();

            EmptyClipboard();

            void* handle = GlobalAlloc(2, text.length + 1);
            void* ptr    = GlobalLock(handle);
            memcpy(ptr, toStringz(text), text.length + 1);
            GlobalUnlock(handle);

            SetClipboardData(1, handle);
        }
    }
}

version(Linux)
{
    string readFromClipboard()
    {
        return "";
    }

    void writeToClipboard(string text)
    {
    }
}

string getInputText(string inputFile, bool fromClipboard, string[] args)
{
    if (!isatty(0))
    {
        return stdin.byLineCopy.array.join("\n");
    }
    else if (fromClipboard)
    {
       return readFromClipboard();
    }
    else if (!inputFile.empty)
    {
        return readText(inputFile);
    }
    else
    {
        return args[1..$].join(" ");
    }
}

void printFunctionList(const Algorithms algorithms, string filter)
{
    string result;

    size_t maxAlgorithmWidth;

    foreach(algorithm; algorithms)
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

    writeln(result);
}

void printHelpOnFunction(const Algorithms algorithms, string filter)
{
    string result;

    auto algorithm = algorithms.closest(filter)[0];

    writeln(algorithm.help);
}

