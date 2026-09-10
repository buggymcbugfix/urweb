Here we test the merging of command-line arguments with urp directives:
for instance, [precedence.urp](../precedence.urp) has `dbms postgres` and
on the command-line we pass `-dbms sqlite`. Command-line arguments should always
take precedence over project file directives.