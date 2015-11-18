import std.getopt;
import std.stdio;
import std.string;

import CountAlgorithms;
import CapitalisationAlgorithms;
import OrderAlgorithms;
import SearchReplaceAlgorithms;

int main(string[] args)
{
    try
    {
        string functionName;
        bool ignoreCase;
        string listFunctionsFilter;
        bool reverseOutput;
        string[] params;

        auto options = getopt(args,
            "function|f", "Function to process the supplied text with.", &functionName,
            "ignore-case|c", "Ignore case.", &ignoreCase,
            "list-functions|l", "List available text processing functions.", &listFunctionsFilter,
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

        auto text = args[1..$].join(" ");

        auto func = algorithms.find(functionName);
        writeln(func.process(text, params, ignoreCase, reverseOutput));

        return 0;
    }
    catch (Exception e)
    {
        writeln("Error: ", e.msg);

        return 1;
    }
}
