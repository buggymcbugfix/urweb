A schema that cannot be written.  The CHECK embeds `{[limit]}`, and `limit`
is a call the compiler does not fold to a constant (`strlen "abcdefg"`; `3 +
4` or `Option.get 0 (Some 7)` would have been folded), so the constraint is
still an expression when the schema is due and cjrize reports it.  The
golden is that diagnostic: the sqlify phase writes nothing half-determined,
and the compiler before it rejected the same program at code generation
with the same message.
