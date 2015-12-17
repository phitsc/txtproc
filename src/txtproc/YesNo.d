import std.uni : icmp;

enum YesNo
{
    yes,
    no
}

YesNo yesNo(string yn)
{
    if (!icmp(yn, "y") || !icmp(yn, "yes"))
    {
        return YesNo.yes;
    }
    else if (!icmp(yn, "n") || !icmp(yn, "no"))
    {
        return YesNo.no;
    }
    else
    {
        throw new Exception(yn ~ " is neither yes nor no.");
    }
}
