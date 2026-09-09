The sql family
==============

The golden is the schema the compiler generates for the `-dbms` named in
`args`, so the same program under `sqlite`, `postgres` and `mysql` is three
cases in three subdirectories next to it, and the differences between the
backends — how names are mangled, which types they map to, how sequences,
primary keys, foreign keys and views come out — are pinned down side by
side where they can be compared.

The schema is written just before the C compiler runs, and no `-stop` phase
sits between the two, so the family compiles the program for real into a
temporary directory and reads the schema back, ignoring what becomes of the
C.  That costs under a second for a small program and works even for
`mysql`, which cannot be linked here: the schema is already on disk by the
time the link fails.  A compiler error leaves no schema, and then the
diagnostics are the golden, as in the other families.
