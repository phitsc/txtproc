module io;

void writeline(string text)
{
    import std.stdio;
    stdout.rawWrite(text ~ "\n");
}
