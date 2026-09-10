The sql family
==============

The golden is the schema the compiler generates for the `-dbms` named in
`args`, so the same program under `sqlite`, `postgres` and `mysql` is three
cases in three subdirectories next to it, and the differences between the
backends — how names are mangled, which types they map to, how sequences,
primary keys, foreign keys and views come out — are pinned down side by
side where they can be compared.

The schema is written by the `sqlify` phase, which sits right after the
first reduction of the monomorphic program — the earliest point at which
the table declarations' constraints and the views' queries are plain
strings — so the family stops there with `-stop sqlify`: no code
generation, no C compiler, and `mysql`, which cannot be linked here, is no
different from the others.  `-stop sqlify` on its own prints the schema,
which is handy at the shell; the family reads the `-sql` file, the thing
users actually get.  A compiler error leaves no schema, and then the
diagnostics are the golden, as in the other families.
