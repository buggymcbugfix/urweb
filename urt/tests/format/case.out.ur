(* On one line, with and without the leading bar. *)
fun noneToZero (o : option int) : int = case o of Some n => n | None => 0

fun noneToZero' (o : option int) : int = case o of Some n => n | None => 0

(* Broken: the branches at the level of `case`, each with a leading bar,
 * however they were written. *)
fun any [a ::: Type] (p : a -> bool) (xs : list a) : bool =
	case xs of
	| x :: xs => if p x then True else any p xs
	| [] => False

fun any' [a ::: Type] (p : a -> bool) (xs : list a) : bool =
	case xs of
	| x :: xs => if p x then True else any p xs
	| [] => False

fun any'' [a ::: Type] (p : a -> bool) (xs : list a) : bool =
	case xs of
	| x :: xs => if p x then True else any p xs
	| [] => False

(* A branch body that does not fit on the branch line, one level deeper. *)
fun classify r =
	case r of
	| {Ready = True, ...} =>
		debug "ready";
		return r
	| _ =>
		return r

(* Patterns: constructors with arguments, tuples, records with and without
 * `...`, literals, lists, nesting, wildcards; as written, spacing
 * collapsed. *)
fun patterns x =
	case x of
	| Leaf => 0
	| Node (l, r) => f l + f r
	| Pair (Some a, None) => a
	| {A = 1, B = "one", C = #"c"} => 1
	| {A = a, ...} => a
	| 1 :: 2 :: rest => length rest
	| (a, (b, c)) => a + b + c
	| (Inl x, Inr y) => x - y
	| Some (Some (Some x)) => x
	| Some _ => -1
	| _ => 0

(* String patterns. *)
fun parse s =
	case s of
	| "one" => Some 1
	| "two" => Some 2
	| "" => None
	| _ => None

(* Nested: a `case` in a branch is written in parentheses unless it is
 * the last branch; the inner one at one level deeper. *)
fun nested x y =
	case x of
	| None =>
		(
			case y of
			| None => 0
			| Some b => b
		)
	| Some a =>
		case y of
		| None => a
		| Some b => a + b

fun nested' x y = case x of None => (case y of None => 0 | Some b => b) | Some a => a

(* In a monadic bind and as an argument, parenthesised. *)
fun bound x =
	n <- (case x of None => return 0 | Some n => return n);
	m <-
		(
			case x of
			| None => return 0
			| Some n => return (n + 1)
		);
	return (n + m)

fun arg x = f (case x of None => 0 | Some n => n) (case x of None => "" | Some _ => "some")

(* A branch with a `fn` body, a `let` body and an `if` body. *)
fun bodies x =
	case x of
	| None => fn y => y
	| Some 0 =>
		let
			val z = 1
		in
			fn y => y + z
		end
	| Some n =>
		if n > 0 then
			fn y => y + n
		else
			fn y => y - n

(* The scrutinee: applications, records, operators. *)
fun scrutinees x y =
	case (f x y, x = y) of
	| (Some r, True) => r
	| (Some r, False) => r + 1
	| (None, _) => 0

(* Aligned `=>`, as the author had them. *)
fun toEnum i =
	case i of
	| 1  => Trousers
	| 10 => Any
	| _  => argumentError i

(* Touching `=>` in one branch: single spaces everywhere. *)
fun fromEnum d =
	case d of
	| Saturday => 1
	| Sunday => 2
	| _ => 0

(* Comments before branches and after them. *)
fun commented x =
	case x of
	(* the happy path *)
	| Some n => n (* found *)
	(* nothing there *)
	| None => 0
