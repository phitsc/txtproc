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
        return unittest_main;
    }
    else
    {
        return txtproc_main(args);
    }
}

