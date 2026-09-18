(* Type annotations of every shape, on one line. *)
val a : int = 0
val b : list (option string) = []
val c : int -> string -> bool = fn _ _ => True
val d : {A : int, B : string} = {A = 1, B = ""}
val e : (int * string) = (1, "")
val f : $[A = int, B = string] = {A = 1, B = ""}
val g : $(map option [A = int]) = {A = None}
val h : transaction {} = return {}
val i : xbody = <xml/>

(* Arrow chains broken by the author: one component per line at one
 * level, the arrows trailing. *)
val update :
	int ->
	string ->
	transaction {}
=
	fn _ _ => return {}

fun long
	[a ::: Type]
	(x : a)
	: a
	-> a
	-> a
=
	fn _ _ => x

(* Record types: like records, broken with one field per line; a
 * trailing comma is kept. *)
type point = {X : int, Y : int}

type user =
	{
		Id : int,
		Name : string,
		Email : option string
	}

type trailing =
	{
		Id : int,
		Name : string,
	}

(* Aligned colons, kept as the author had them. *)
type item =
	{
		Index    : int,
		Name     : string,
		Quantity : int
	}

(* Type-level records with `=`, aligned or not. *)
con fields = [A = int, B = string]

con fields' =
	[
		A   = int,
		Bb = string
	]

con names = [A, B, C]

(* Applications, `$`, `map`, `++`, kinds and type-level functions. *)
con rows = [Id = int] ++ [Name = string]
con rows' =
	[Id = int]
	++ [Name = string]
	++ [Email = string]
con optional = map option rows
con record = $(map option rows)
con f (t :: Type) = t
con g (t :: Type) (u :: Type) = t * u
con k :: Type -> Type = option
con constant = fn t :: Type => int
con app = f int
con nameOf :: Name = #Name

(* Polymorphic types with explicit and implicit quantifiers and a
 * disjointness constraint. *)
val poly : t ::: Type -> t -> t = fn x => x
val poly' : nm :: Name -> t ::: Type -> r ::: {Type} -> [[nm] ~ r] => $([nm = t] ++ r) -> t = fn x => x.nm

(* Type-level `if` is not a thing, but tuples of types and nested
 * applications are. *)
type nested = list (list (option (int * string)))
type fn' = (int -> int) -> int

(* Types in signatures of local declarations. *)
fun local () =
	let
		val x : int = 1
		fun k (y : int) : string = show y
	in
		k x
	end
