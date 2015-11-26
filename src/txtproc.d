
import txtprocmain;

version(unittest)
{
    import unittestmain;
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

