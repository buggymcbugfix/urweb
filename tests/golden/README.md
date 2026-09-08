Golden Tests
============

The purpose of these is to keep large amounts of input/output pairs in order to probe and track changes in the compiler.  As you work on the compiler, it may happen that large numbers of golden test cases change.  You are not expected to validate every changed golden file---these tests are somewhat like a _contrast agent_ that points to changes and tracks them in version control.

Running
-------

    make check-golden          # every family
    make check-golden-urp      # one family (see GOLDEN_FAMILIES in Makefile.am)
    make update-golden         # accept the current output as the new expected output

`make check` includes `check-golden`.  The runner can also be called directly, which is how you narrow an update down to the cases you meant to change:

    tests/golden/run.sh                     # every family
    tests/golden/run.sh <FAMILY>/<CASE>     # one case
    tests/golden/run.sh --update <FAMILY>   # accept new output for one family

It runs `../../bin/urweb` unless `URWEB` names another compiler, with `URWEB_FLAGS` overriding the flags it is given.

Adding a case
-------------

Create the directory with its `.ur`/`.urp` files, an `args` file holding the command line, and an empty `expected`; then run the runner with `--update`/`-u` on it and read the diff before committing.  The header of `tests/golden/run.sh` documents the layout and lists the families; a new family is a shell function there, not a new runner.