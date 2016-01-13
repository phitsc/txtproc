module txtproc.lineendings;

enum LineEndings
{
    dontChange,
    unix,
    windows
}

LineEndings lineEndings(string le) pure
{
    import std.uni : icmp;

    if (!icmp(le, "d") || !icmp(le, "dontchange"))
    {
        return LineEndings.dontChange;
    }
    else if (!icmp(le, "u") || !icmp(le, "unix"))
    {
        return LineEndings.unix;
    }
    else if (!icmp(le, "w") || !icmp(le, "windows"))
    {
        return LineEndings.windows;
    }
    else
    {
        throw new Exception(le ~ " does not specify a valid line ending.");
    }
}

unittest
{
    assert(lineEndings("dontChange") == LineEndings.dontChange);
    assert(lineEndings("d")          == LineEndings.dontChange);
    assert(lineEndings("DontChange") == LineEndings.dontChange);
    assert(lineEndings("D")          == LineEndings.dontChange);

    assert(lineEndings("unix") == LineEndings.unix);
    assert(lineEndings("u")    == LineEndings.unix);
    assert(lineEndings("UNIX") == LineEndings.unix);
    assert(lineEndings("U")    == LineEndings.unix);
    assert(lineEndings("Unix") == LineEndings.unix);

    assert(lineEndings("windows") == LineEndings.windows);
    assert(lineEndings("w")       == LineEndings.windows);
    assert(lineEndings("WINDOWS") == LineEndings.windows);
    assert(lineEndings("W")       == LineEndings.windows);
    assert(lineEndings("Windows") == LineEndings.windows);

    import std.exception;

    assertThrown(lineEndings(""));
    assertThrown(lineEndings("garbage"));
    assertThrown(lineEndings("Dont_change"));
}

auto changeLineEndings(string input, string lineEndingsParam) pure
{
    const le = lineEndings(lineEndingsParam);

    final switch (le)
    {
        case LineEndings.dontChange:
            return input;

        case LineEndings.unix:
            import std.string : replace;
            return input.replace("\r\n", "\n");

        case LineEndings.windows:
            import txtproc.textalgo : chars;
            import std.algorithm : reduce;
            import std.conv : text;
            import std.range : back;

            return reduce!((a, c) => a ~ (c == '\n' && a.back != '\r' ? "\r\n" : c.text))("", input.chars);

    }
}

unittest
{
    import std.stdio : writeln;

    assert(changeLineEndings("", "d") == "");
    assert(changeLineEndings("", "u") == "");
    assert(changeLineEndings("", "w") == "");

    assert(changeLineEndings("this has no line endings", "d") == "this has no line endings");
    assert(changeLineEndings("this has no line endings", "u") == "this has no line endings");
    assert(changeLineEndings("this has no line endings", "w") == "this has no line endings");

    assert(changeLineEndings("line\r\nendings\r\ntest", "d") == "line\r\nendings\r\ntest");
    assert(changeLineEndings("line\r\nendings\ntest", "d")   == "line\r\nendings\ntest");
    assert(changeLineEndings("line\nendings\ntest", "d")     == "line\nendings\ntest");

    assert(changeLineEndings("line\r\nendings\r\ntest", "u") == "line\nendings\ntest");
    assert(changeLineEndings("line\r\nendings\ntest", "u")   == "line\nendings\ntest");
    assert(changeLineEndings("line\nendings\ntest", "u")     == "line\nendings\ntest");

    assert(changeLineEndings("line\r\nendings\r\ntest", "w") == "line\r\nendings\r\ntest");
    assert(changeLineEndings("line\r\nendings\ntest", "w")   == "line\r\nendings\r\ntest");
    assert(changeLineEndings("line\nendings\ntest", "w")     == "line\r\nendings\r\ntest");
}
