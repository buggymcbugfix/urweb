# The style

Taken from the prevalent forms in the warenwirtschaft repository.  Where
the repository has two forms, the one used more often won; the counts are
noted.

## Principles

1. Indentation is one tab per nesting level, and nothing else: no line
   starts with a space.  Alignment with spaces exists in one place, after
   the names of record fields, SET clauses and case patterns (see
   Alignment).

2. A construct is either on one line or fully broken: each of its parts on
   its own line, one level deeper than the construct.  Nothing in between.

3. The author decides what is broken, by writing a line break inside a
   construct (`-width N` adds a limit: what is longer than N columns is
   broken too; the default is no limit).  A construct containing a
   multi-line part is broken.  A construct the author wrote on one line
   stays on one line.

4. Blank lines between declarations and statements are the author's, at
   most one.  Trailing whitespace is removed; the file ends with one
   newline.

## Declarations

```
fun name p1 p2 : t = body            -- fits

fun name p1 p2 : t =                 -- body on its own line
	body

fun name                             -- author broke the head (line break
	p1                                  between its parts): one part per
	p2                                  line, then `=` at the head's level
	: t
=
	body

val name p1 :                        -- only the type spans lines: `:` ends
	transaction                         the head's line, `=` on its own
		{
			A : int
		}
=
	body
```

The same for `val`, `val rec`, `fun ... and ...` (`and` at the level of
the keyword), and `val`/`fun` inside `let`.  A type that spans lines in a
broken head: `:` alone, the type one level deeper.  Likewise `structure S
: sig ... end = struct ... end` with a signature that spans lines: the
signature below `:`, `=` alone, the structure below it.

`struct ... end` and `sig ... end` stay on one line when written on one
line; broken, the keywords are at the construct's level and the
declarations one deeper, one per line.

`con`, `type`, `datatype`, `table`, `cookie`, `view`, `structure`,
`signature`, `functor`: the keyword line, then the body one level deeper
when it does not fit on the line.

```
datatype ty =
	| A
	| B of int

table tb :
	{
		Id : int,
		Name : string
	}
	PRIMARY KEY Id,
	CONSTRAINT FK
		FOREIGN KEY Id
		REFERENCES other(Id)

functor Make
	(
		M : sig
			val x : int
		end
	)
	: sig
		val y : int
	end
=
	struct
		...
	end

open Crud.Make
	(
		struct
			...
		end
	)
```

## Expressions

Application: the head, then the arguments the author kept on the head's
line as long as they are single words (`oneRow _LOC_`, `forM items`), then
every remaining argument on its own line one level deeper.  `Page.mk` with
each argument on its own line stays that way.

```
query
	(
		SELECT ...
	)
	(
		fn r acc =>
			...
	)
	{Matching = [], Rest = []}
```

Parentheses, records, lists, tuples: `(`/`{`/`[` on its own line, the
content one level deeper, the closing bracket back at the opening level.
Record fields one per line with the comma after the field (413 `{` alone
on a line against 19 `f {`; 2514 trailing commas against 336 leading).  A
trailing comma the author wrote is kept.

```
{
	Selection = r --- [MatchingStyle = _],
	Out = {Styles = styles, Fabrics = fabrics}
}
```

### Alignment

In a record (`{A = x}`, and the types `{A : t}` and `[A = t]`), in the
`SET` clause of an `UPDATE` or `INSERT` and in the branches of a `case`,
the author decides whether the `=`, `:` or `=>` are aligned, by the
spacing before them, checked in this order:

1. any name written directly against its separator (`A= x`, `Saturday=>`):
   no alignment, one space everywhere;
2. otherwise, any name followed by more than one space (`Email   = x`):
   aligned, every separator in the column after the widest name;
3. otherwise one space everywhere.

Alignment only shows when the construct is broken (it is meaningless on
one line).  Spacing after the separator is not preserved: one space, or
the body on the next line.  In a `case`, the pattern follows the bar after
one space; a multi-line pattern (or name) turns alignment off for its
construct.  (128 aligned `=` lines against 0 `A=` in the repository.)

```
{
	Email         = checkout.Email,
	PaymentMethod = paymentMethod
}

case i of
| 1  => Trousers
| 10 => Any
| _  => argumentError _LOC_ i
```

Monadic sequences: one statement per line; a right-hand side that spans
lines goes below its `<-`, one level deeper, with the `;` after it.

```
rows <-
	queryL1
		(
			SELECT ...
		);
return rows
```

`case`: the branches at the level of `case`, every branch with a leading
bar; a branch body that does not fit on the branch line one level deeper.
On one line: `case o of Some n => n | None => 0`.

```
case xs of
| x :: xs => f x
| [] =>
	logDebug _LOC_ "empty";
	return {}
```

`if`: `if c then` / branch / `else` / branch, with `else if` chains at
one level and broken as a whole when any link is; a condition that spans
lines goes below `if`, one level deeper, with `then` back at the level of
`if`.  `let`: on one line when written so, else `let` / declarations /
`in` / body / `end`, the declarations and the body one level deeper.
`fn args =>` with the body one level deeper; parameters the author
spread over lines go one per line one level deeper, with `=>` back at the
level of `fn`, like the head of a `fun`.

```
if
	x > 0
		&& y > 0
then
	"some"
else
	"none"
```

A `case` or `if` that is the right-hand side of `<-` or a statement in a
sequence needs parentheses, which the language demands; they follow the
bracket rule.

Operator chains: `::` with the operator on its own line and the operands
one level deeper (232 against 88 + 91 for the other two forms); every other
operator leading its operand, one level deeper than the first operand
(`^` 55, `|>` 56, `++` 64 against 17).

```
	(
			a
		::
			b
		::
			[]
	)

Url.absolute "/img/"
	^ replaceSpace r.Style
	^ "/"
```

Types: arrow chains with the arrows trailing, one component per line at
one level (372 against 83); record types like records.

```
val updateStock :
	ERP.idProduct ->
	Sizes.sizeId ->
	transaction {}
```

## XML

The author's lines are kept.  Each line is one level deeper than the
line that opened the innermost element around it, however many elements
that line opened (`<xml><body>` on one line opens one level, not two); a
line starting with a closing tag sits at the level of the line that
opened the element.  Whitespace-only text at the ends of a line is
indentation and is replaced; any other whitespace run in text becomes one
space; text is never joined or split.  Where the source had no whitespace
between two nodes there is none in the output; where it had some there is
some (adjacent whitespace collapses in a browser; its absence does not).

A tag whose attributes the author spread over lines: `<tag` / one
attribute per line one level deeper / `>` (or `/>`) at the tag's level.  An
attribute value or a `{...}` / `{[...]}` hole whose expression spans lines:
the brackets on their own lines, the expression one level deeper.  A
self-closing tag on one line ends ` />`: `<br />`, `<textbox{nm} source={s} />`
(the top-level empty literal `<xml/>` is one token to the lexer and stays
as it is).

`<pre>` and `<textarea>` elements are printed exactly as written.

```
<div
	dynClass={
		s <- signal sc;
		return (if s then Class.a else null)
	}
>
	{[
		i18n ctx
			{
				De = "…",
				En = "…"
			}
	]}
	<span>{[x]}</span>{[y]} <b>z</b>
</div>
```

## SQL

A query or DML statement (`(SELECT ...)`, `(UPDATE ...)`, `view v = ...`)
is on one line, or broken with every clause on its own line at the
statement's level: `SELECT`, `FROM`, `WHERE`, `GROUP BY`, `HAVING`,
`ORDER BY`, `LIMIT`, `OFFSET`; `UPDATE t`, `SET`, `WHERE`; `DELETE FROM
t`, `WHERE`; `INSERT INTO t`, `(columns)`, `VALUES`, `(values)`, or `SET`.
The parentheses around a statement follow the bracket rule.  One line
break between clauses, or a clause that spans lines, breaks the whole.

A clause's content follows its keywords on the line, or, when the author
broke after the keywords or broke a list of items, one level deeper: lists
(select items, `SET` assignments, `GROUP BY`, `ORDER BY`, the columns and
values of an `INSERT`) one item per line with the comma after it, like
records; a bracketed content that spans lines goes below.  `JOIN`s are at
the level of `FROM` (whatever the join), each `ON` one level deeper, a
subquery below its `JOIN`.  `AND`/`OR` chains have their operators one
level deeper than the clause's keyword, leading their operands, whether
the first operand is on the keyword's line or below it; an operand that
spans lines (a parenthesised chain) goes below its operator.  Words are
separated by one space; `COUNT( * )` keeps its spaces, since `(*` would
open a comment; `SUM(x)`, `lower(x)` and `t(Id)` after `REFERENCES` have
none.

```
queryL1
	(
		SELECT
			U.Id AS Id,
			COUNT( * ) AS Orders
		FROM tbUser AS U
		JOIN tbOrder AS O
			ON O.UserId = U.Id
		WHERE U.Active
			AND U.Age >= 18
		GROUP BY U.Id
		ORDER BY Orders DESC
	)

dml
	(
		UPDATE tbUser
		SET
			Name   = {[name]},
			Active = FALSE
		WHERE Id = {[id]}
	)
```

Table declarations: the type, `PRIMARY KEY`, and each `CONSTRAINT` on
its own line one level deeper than `table` when broken, the comma after
the constraint; a constraint's parts (`FOREIGN KEY`, `REFERENCES`, `ON
DELETE ...`) on its line or one per line one level deeper.

## Everything else

Patterns, kinds and the rest are printed as written: their lines
re-indented to the nesting of the construct, by tabs alone, whitespace
inside a line collapsed to one space; expressions and types inside them
formatted by the rules above.

## Comments

A comment on the line of a token stays on that line.  A comment on its own
line goes with the construct that follows it, at that construct's level;
one directly after a declaration or statement and followed by a blank line
belongs to what precedes it.  Comments on one line in the source stay on
one line.  A multi-line comment keeps its shape: its continuation lines
move with its first line, by whole tabs.
