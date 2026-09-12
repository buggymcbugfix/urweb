The Ur/Web Toolbox
==================

`urt` is one program with a command for each tool; `make -C urt` builds it
from the C beside it, and `urt --help` lists the commands.  `derivation.nix`
builds and checks it under nix (`nix-build urt` from the top), and the
development shell of `shell.nix` has it on the PATH.

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

Style
-----

C99, and nothing that is not POSIX.  Braces on every `if`, `for` and
`while`, K&R style, one statement per line; four spaces; a comment of a
line or two on every function saying what it is for.
