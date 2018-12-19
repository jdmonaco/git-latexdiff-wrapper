## git-latexdiff.sh

This wrapper script attempts to compile 'tracked changes' files between git
commits (or between a commit and the current working copy) of a LaTeX document.
This script does not do much testing or verification; it assumes that the
commits (or working copy) provide compilable documents that `latexdiff`
([CTAN](http://www.ctan.org/tex-archive/support/latexdiff/)) can handle.
It checks out the commits/branches/tags that you specify into temporary
folders, runs `latexdiff` on them, compiles the result, and moves the diff'd
PDF back to the document's directory. To install, create a symbolic link to
`git-latexdiff.sh` called `git-ldiff` (or whatever you prefer) somewhere on your
`$PATH`.

    Usage: git-ldiff [-m <name>] [-x] [-o <opts>] [-b] <base> [-r <revision>]

    Arguments:
    -m,--main       main document name (default, 'main')
    -x,--xelatex    use xelatex instead of pdflatex
    -o,--options    addtional latexdiff arguments (--flatten is handled)
    -b,--base       git commit reference for comparison point
    -r,--revision   revision commit (default, working copy)

    Only the <base> commit reference is required.

The base and revision values can be git references of any sort (tags, branches,
commit hashes, etc.) that are accepted by `git checkout`.

Notes:

- The script passes the option `--append-safecmd=$ROOT/.append-safecmd` if you
have a file called `.append-safecmd` in the document's directory; see `man
latexdiff` for more about safe commands.
- It will similarly pass `--append-textcmd=$ROOT/.append-textcmd` if there is a
`.append-textcmd` file.
- If you have `\include` or `\input` commands to bring in
other files, the script will use the `--flatten` option,
meaning that you will also need `latexdiff` version 1.0.1+
([CTAN](http://www.ctan.org/tex-archive/support/latexdiff/)).

