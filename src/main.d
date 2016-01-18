module main;

version(unittest)
{
    import unittestmain;
}
else
{
    import txtprocmain;
}

int main(string[] args)
{
    version(unittest)
    {
        return unittest_main(args);
    }
    else
    {
        import std.array : empty;
        import std.stdio : stderr, stdout;

        try
        {
            const result = txtproc_main(args);

            if (!result.empty)
            {
                stdout.rawWrite(result ~ "\n");
            }

            return 0;
        }
        catch (Exception e)
        {
            import debugflag;
            import std.conv : text;

            stderr.rawWrite("Error: " ~ e.msg ~ "\n");

            if (printDebugOutput)
            {
                stderr.rawWrite(e.file.text ~ "(" ~ e.line.text ~ ")\n");
                stderr.rawWrite(e.info.text ~ "\n");
            }

            return 1;
        }
    }
}

