(* On one line, and one line per part. *)
val a = if 1 + 2 = 3 then "yes" else "no"

val b =
	if 1 + 2 = 3 then
		"yes"
	else
		"no"

(* One line break inside breaks the whole construct. *)
val c = if 1 + 2 = 3 then "yes"
	else "no"

(* `else if` chains stay at one level, however they were written. *)
fun sign n = if n > 0 then 1 else if n < 0 then -1 else 0

fun describe n =
	if n > 0 then
		"positive"
	else if n < 0 then
		"negative"
	else
		"zero"

fun describe' n =
	if n > 0 then "positive"
	else
		if n < 0 then "negative"
		else "zero"

(* Nested in the branches: an `if` in the `then` branch, one in the `else`
 * branch with parentheses, one without. *)
fun nested x y =
	if x then
		if y then 1 else 2
	else
		(if y then 3 else 4)

fun nested' x y z =
	if x then
		if y then
			1
		else
			2
	else if z then
		3
	else
		if y then 4 else 5

(* Conditions with operators, parentheses and function calls. *)
fun cond x y = if (x > 0 && y > 0) || not (x = y) then "some" else "none"

fun cond' x y =
	if
		x > 0
		&& y > 0
		&& x <> y
	then
		"some"
	else
		"none"

(* An `if` as an argument, in parentheses, on one line and broken. *)
fun arg x = f (if x then 1 else 2) 3

fun arg' x =
	f
		(
			if x then
				1
			else
				2
		)
		3

(* Branches that are records, applications and sequences. *)
fun branches x =
	if x then
		{A = 1, B = "one"}
	else
		{A = 2, B = "two"}

fun branches' x = if x then f 1 2 else g (h 3)

(* As the right-hand side of a monadic bind, which needs parentheses: on
 * the line, and below with the parentheses on their own lines. *)
fun bound x =
	y <- (if x then return 1 else return 2);
	z <-
		(
			if y > 1 then
				return "big"
			else
				return "small"
		);
	return (y, z)

(* As a statement in a sequence, which needs parentheses, as do sequences
 * in the branches. *)
fun statements x =
	(if x then debug "yes" else debug "no");
	(
		if x then
			(
				debug "one";
				debug "two"
			)
		else
			return ()
	);
	return ()

(* Under a `case`, and a `case` under an `if`. *)
fun underCase o =
	case o of
	| None => if True then 0 else 1
	| Some n =>
		if n > 10 then
			n
		else
			0

fun overCase o x =
	if x then
		case o of
		| None => 0
		| Some n => n
	else
		(case o of None => 1 | Some _ => 2)

(* An `if` in a condition. *)
val twisted = if (if True then False else True) then 1 else 2

(* Long lines stay long: there is no width limit by default. *)
val long = if someFunction someArgument anotherArgument = someOtherFunction someArgument then someResult else someOtherResult
