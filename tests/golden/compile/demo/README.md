The demos, compiled
===================

One case per program in `demo/`.

Each `args` registers the demo directory as a path root before naming the program:

    -path DEMO ../../../../../demo ../../../../../demo/link

This keeps absolute paths out of golden tests.

NB: `demo` itself if not in-tree and thus has no case: it is simply generated from the individual demos by `make check`.