import std.array;
import std.getopt;
import std.file;
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
        string functionName;
        bool ignoreCase;
        string inputFile;
        string listFunctionsFilter;
        bool modifyInputFile;
        bool reverseOutput;
        string[] params;

        auto options = getopt(args,
            "function|f", "Function to process the supplied text with.", &functionName,
            "ignore-case|c", "Ignore case.", &ignoreCase,
            "input-file|i", "Input file containing text to process.", &inputFile,
            "list-functions|l", "List available text processing functions.", &listFunctionsFilter,
            "modify-input-file|m", "Modify the input file in-place.", &modifyInputFile,
            "parameter|p", "Parameter to pass to processing function. Supply multiple times if necessary.", &params,
            "reverse-output|r", "Reverse the order of the output.", &reverseOutput
        );

        if (options.helpWanted)
        {
            defaultGetoptPrinter("Txtproc", options.options);

            return 0;
        }

        auto algorithms = new Algorithms;
        algorithms.add(new CountAlgorithms);
        algorithms.add(new CapitalisationAlgorithms);
        algorithms.add(new OrderAlgorithms);
        algorithms.add(new SearchReplaceAlgorithms);

        if (listFunctionsFilter)
        {
            writeln(algorithms.toString(listFunctionsFilter));

            return 0;
        }

        string getInputText(string inputFile, string[] args)
        {
            if (!isatty(0))
            {
                return stdin.byLineCopy.array.join("\n");
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

        const func = !functionName.empty ? algorithms.find(functionName) : new Algorithm("", "", (string text, string[], bool, bool) => text);
        const outputText = func.process(getInputText(inputFile, args), params, ignoreCase, reverseOutput);

        if (modifyInputFile)
        {
            File(inputFile, "w").rawWrite(outputText);
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
