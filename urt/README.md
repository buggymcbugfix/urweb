The Ur/Web Toolbox (Urt)
========================

NB: Urt is a tool I slopped together as a prototype. If this evolves into something useful, it shall be rewritten properly.


`urt snapshot`
--------------

Create, validate and manage snapshots of the compilation pipeline for an
Ur/Web project: `urt snapshot --help` describes the layout and the usage.

Checks
------

`urt/check` holds the program to the transcripts under `urt/tests`, on a
fixture tree with a stand-in compiler, scripted and on a pseudo-terminal;
`make -C urt check` runs that, and `urt/check -u` rewrites what it
expects.

Sure... actually the tests are pretty crappy afaict.

Style
-----

C99, and nothing that is not POSIX.  Braces on every `if`, `for` and
`while`, K&R style, one statement per line; four spaces; a comment of a
line or two on every function saying what it is for.
