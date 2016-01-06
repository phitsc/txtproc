module unittestmain;

version(unittest)
{

import std.algorithm;
import std.array;
import std.file;
import std.stdio;
import std.string;
import std.typecons;

import txtprocmain;

enum commentChar = '#';
enum separatorChar = "%";

auto getTests(string fileName)
{
    alias Test = Tuple!(string[], "params", string, "input", string, "output", size_t, "line");

    string[string] referenceTexts;
    Test[] tests;
    string section;
    string refTextNo;
    string[] params;
    string input;
    string output;

    size_t lineNo, currentTestLineNo;

    enum State
    {
        ReadParamOrRefText,
        ReadInput,
        ReadOutput,
        SectionDone
    }
    State state;

    foreach (line_; fileName.readText.lineSplitter!(KeepTerminator.yes))
    {
        lineNo++;

        string line = line_.chomp;

        if (line.startsWith(commentChar))
        {
            continue;
        }
        else if (line.startsWith(separatorChar ~ separatorChar))
        {
            state = State.SectionDone;
            output = section.chomp;
            section = "";
        }
        else if (line.startsWith(separatorChar))
        {
            if (line.length > 1)
            {
                if (state == State.ReadInput)
                {
                    section = referenceTexts[line[1..$]];
                }
                else
                {
                    refTextNo = line[1..$];
                    state = State.ReadParamOrRefText;
                }
            }
            else
            {
                if (state == State.ReadParamOrRefText)
                {
                    params = section.splitLines.remove!(a => a == "");
                    state = State.ReadInput;
                }
                else if (state == State.ReadInput)
                {
                    input = section.chomp;
                    state = State.ReadOutput;
                }

                section = "";
            }
        }
        else
        {
            section ~= line_;
        }

        if (state == State.SectionDone)
        {
            if (!refTextNo.empty)
            {
                referenceTexts[refTextNo] = output;
                refTextNo = "";
            }
            else
            {
                tests ~= Test(params, input, output, currentTestLineNo);
            }

            currentTestLineNo = lineNo + 1;
            state = State.ReadParamOrRefText;
            section = "";
        }
    }

    //writeln(tests);

    return tests;
}

int unittest_main()
{
    int status;

    foreach (fileName; dirEntries("test", SpanMode.shallow).filter!(f => f.name.endsWith(".txt")))
    {
        const tests = getTests(fileName);

        foreach (test; tests)
        {
            string[] args = [ "Txtproc" ] ~ [ test.input ] ~ test.params.dup;

            string result;
            if ((txtproc_main(args, &result) == 1) || (result != test.output))
            {
                writeln(format("%s(%s) : %s\n`%s`\n--  !=  --\n`%s`\n", fileName, test.line, test.params.join(" "), result, test.output));
                status = 1;
            }
        }
    }

    return status;
}

}
