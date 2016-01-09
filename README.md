# txtproc

A tool for text processing.

## Usage

**txtproc** is a command line tool to do various text transformations. It is called with some text to transform and a transformation function as input and will return the transformed text as output. For some of the transformation functions additional parameters must be provided as well.

To get a list of all the available transformation functions type:

    ./txtproc --list

A simple example:

    ./txtproc --execute CountWords "Hello world!"

will result in the following output:

    2

Parameters are supplied using the `--parameter` argument:

    ./txtproc --execute SplitIntoLines "one,two,three,four" --parameter ","

will output:

    one
    two
    three
    four

Function names are not case-sensitive, i.e. `SplitIntoLines` and `splitintolines` is the same. Actually, **txtproc** will apply the function that most closly matches the supplied function name, so `splin` will also split the input text into lines (at least until a function is added which matches `splin` better than `SplitIntoLines`). Function names within **txtproc** are unique though and an exact match will always be preferred. To learn which function **txtproc** chooses for a provided function name, either the `list` or the `help` option can be used. While

    ./txtproc --list --execute split

will print a list of all functions sorted by how closely they match the supplied function to execute (i.e. the first one would be chosen)

    ./txtproc --execute split --help

will print a description of the specified function (i.e. of the one **txtproc** chooses to execute), including information about required (and optional) parameters if available.

Input text can be supplied:

* on the command line (like in the examples above)
* via a file (using the `--file` parameter)
* from `stdin` when **txtproc** is used in a [pipeline](https://en.wikipedia.org/wiki/Pipeline_(Unix))
* via the clipboard (built-in on Windows or using a tool like xclip on Linux)

Output text can go:

* to `stdout`, i.e. the console window or another tool in a pipeline (which again can be **txtproc**)
* back to the input file (i.e. modifying the input file)
* a new file (using redirection, i.e. the `>` symbol)
* back to the clipboard (built-in on Windows or using a tool like xclip on Linux)

## Build instructions

**txtproc** is written in the [D](http://www.dlang.org/) programming language. To build from source, with a D compiler and the D package manager [DUB](http://code.dlang.org/) installed, change into the `txtproc` root directory and type:

    dub build

The executable will be built in the `bin` subdirectory.

## Tests

**txtproc** comes with automated tests which can be built and run as follows:

    dub test

The executable which is built like this will run all the tests specified in all `.txt` files underneath test.
