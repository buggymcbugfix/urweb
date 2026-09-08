How messages name files.  Every source file has a type error, and app.ur
also puts `_LOC_` where an int is expected, so that the elaborator prints
the string `_LOC_` expands to.  The program runs in app/ with `-stop
elaborate`, which overrides the runner's `-stop parseJob`, and `-boot`,
so that the standard library is found in the build tree.

- lib/libmod.ur is reached through `path LIB=../lib` and is named `$LIB/libmod.ur`.
- app/app.ur and app/sub/inner.ur are below the current directory and are named relative to it.
- shared.ur is neither, so it keeps its absolute path (shown as `<tests/golden>/paths/shared.ur`).
