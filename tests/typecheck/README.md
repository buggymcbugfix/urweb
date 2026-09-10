Type checking
=============

The compiler stops after elaboration, and there are two snapshots to be had there.  `stderr.txt` is what the type checker says: a message with its position for a program that does not typecheck.  `typecheck.urs` is what it worked out for a program that does --- the signature of each of the program's modules, in the shape of the .urs someone would have written by hand.

A rejected program keeps both: the diagnostic a person will read, and an empty `typecheck.urs` saying that nothing was inferred.  An accepted one keeps the signatures, which say more than an empty file would: the day inference or the library changes what a function's type is, the diff says which function and how.

Cases run in well under a second, since nothing is generated, which is why a project belongs here rather than under `compile` unless it is really about the code that comes out.
