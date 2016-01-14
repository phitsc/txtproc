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
        return txtproc_main(args);
    }
}

