The typecheck family
====================

`urweb -tc PROJECT` stops after elaboration, so the golden is what the type
checker says: a message with its position for a program that does not
typecheck, and nothing at all for one that does.

That makes the family the natural home for two kinds of case.  One is a
program that ought to be rejected, where the golden is the diagnostic a
person will read, and a change in its wording or its position is worth
seeing in a diff.  The other is a program that ought to be accepted, where
the empty golden is the whole point: it fails the day some change to
inference or to the library stops accepting it.

Cases run in well under a second, since nothing is generated, which is why
a case belongs here rather than in the compile family unless it is really
about the code that comes out.
