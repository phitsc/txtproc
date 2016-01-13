module io;

void writeline(string text)
{
    import std.stdio;
    stdout.rawWrite(text ~ "\n");
}

unittest
{
    import std.exception;

    assertNotThrown(writeline("writeline seems to work"));
}
