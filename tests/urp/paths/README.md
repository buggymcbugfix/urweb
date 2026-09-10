How messages name files.  Every source file has a type error, and `app.ur`
also puts `_LOC_` where an int is expected, so that the elaborator prints the
string `_LOC_` expands to.  The snapshot asks for `typecheck.urs`, which is
what makes the compiler go as far as elaborating and no further; the
diagnostics are in `stderr.txt` and the signatures come out empty, since
there are none.

- `lib/libmod.ur` is reached through `path LIB=../lib` and is named `$LIB/libmod.ur`.
- everything else is below the directory the compiler ran in and is named relative to it.

That second point used to be two: `shared.ur` sat outside the program's
directory and so kept an absolute path.  The compiler now runs from the top
of the tree rather than in `app/`, so nothing here is outside it, and the
absolute case has no project to demonstrate it.
