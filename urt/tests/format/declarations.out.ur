(* Values and functions: on one line, with and without types. *)
val zero = 0
val one : int = 1
val pair : int * string = (1, "one")
fun add x y = x + y
fun add' (x : int) (y : int) : int = x + y
fun id [a] (x : a) = x
fun const [a ::: Type] [b ::: Type] (x : a) (_ : b) : a = x

(* The body on its own line, one level deeper. *)
fun add'' x y =
	x + y

val greeting =
	"hello"

(* A head the author broke: `fun name`, then the parameters one per line,
 * then the type, then `=` at the head's level. *)
fun broken
	[a ::: Type]
	[r ::: {Type}]
	(ctx : context r)
	(f : a -> transaction unit)
	: transaction unit
=
	f ctx

fun manyParams
	[path ::: Type]
	(ctx : context path)
	(name : source string)
	: transaction xbody
=
	return <xml/>

(* Only the type spans lines: the parameters stay on the head's line. *)
val multiLineType r :
	transaction
		{
			A : int,
			B : string
		}
=
	return {A = 1, B = "x"}

(* Patterns as parameters: tuples, records, wildcards, constructors. *)
fun fst (x, _) = x
fun name {Name = n, ...} = n
fun unwrap (Some x) = x
fun compose (f, g) x = f (g x)

(* Polymorphism: explicit and implicit type parameters, kinds,
 * disjointness. *)
fun proj [nm :: Name] [t ::: Type] [r ::: {Type}] [[nm] ~ r] (x : $([nm = t] ++ r)) : t = x.nm
fun length [a] (xs : list a) : int = List.length xs
fun mapRec [r ::: {Type}] (fl : folder r) (x : $r) = @Top.mp [fn t => t] [fn t => option t] (fn [t] x => Some x) fl x

(* `val rec` and `fun ... and ...`, with `and` at the level of the
 * keyword. *)
val rec even = fn n => if n = 0 then True else odd (n - 1)
and odd = fn n => if n = 0 then False else even (n - 1)

fun isEven n = if n = 0 then True else isOdd (n - 1)
and isOdd n =
	if n = 0 then
		False
	else
		isEven (n - 1)

(* `fn` with one and several arguments, bodies on the line and below. *)
val inc = fn x => x + 1
val add3 = fn x y z => x + y + z
val big =
	fn x =>
		let
			val y = x * x
		in
			y + y
		end
val typed = fn (x : int) => x

(* Types and constructors. *)
type name = string
type point = {X : int, Y : int}
type pairOf a = a * a
con fields = [Id = int, Name = string]
con app (f :: Type -> Type) (t :: Type) = f t
con mapped = map option fields
con wild :: Type = int

(* Constraints, sequences, cookies, styles, tasks, policies. *)
constraint [A] ~ [B]
sequence ids
cookie session : {Name : string, Token : string}
style highlighted
task initialize = fn () => return ()
task periodic 60 = fn () => debug "tick"
policy sendClient (SELECT * FROM tbUser WHERE tbUser.Public)

(* Declarations one per line, blank lines kept, at most one. *)
val a = 1
val b = 2

val c = 3
