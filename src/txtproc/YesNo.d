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

unittest
{
    assert(yesNo("yes") == YesNo.yes);
    assert(yesNo("y") == YesNo.yes);
    assert(yesNo("YES") == YesNo.yes);
    assert(yesNo("Y") == YesNo.yes);
    assert(yesNo("Yes") == YesNo.yes);

    assert(yesNo("no") == YesNo.no);
    assert(yesNo("n") == YesNo.no);
    assert(yesNo("NO") == YesNo.no);
    assert(yesNo("N") == YesNo.no);
    assert(yesNo("No") == YesNo.no);
}
