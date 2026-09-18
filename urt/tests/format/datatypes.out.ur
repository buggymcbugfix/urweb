(* On one line, with and without a leading bar. *)
datatype align = Left | Right
datatype align' = Left | Right

(* Broken: one constructor per line, one level deeper, each with a
 * leading bar, however the author wrote them. *)
datatype formatted =
	| Empty
	| Text of string
	| Link of string * string (* the target and the label *)

datatype formatted' =
	| Empty
	| Text of string
	| Link of string * string

datatype formatted'' =
	| Empty
	| Text of string

(* Type parameters, constructor arguments of every shape. *)
datatype either a b = Left of a | Right of b
datatype tree a = Leaf | Node of tree a * a * tree a
datatype record = Rec of {A : int, B : string}
datatype nested = Some' of option (list int)
datatype fn' = Fn of int -> int

(* Mutually recursive datatypes, `and` at the level of the keyword. *)
datatype expr = Num of int | Add of expr * expr | Block of stmt
and stmt = Expr of expr | Seq of stmt * stmt

datatype expr' =
	| Num of int
	| Add of expr' * expr'
	| Block of stmt'
and stmt' =
	| Expr of expr'
	| Seq of stmt' * stmt'

(* A datatype imported from another module. *)
datatype opt = datatype Basis.option

(* Constructors in expressions and patterns. *)
val v = Node (Leaf, 1, Node (Leaf, 2, Leaf))
fun size t =
	case t of
	| Leaf => 0
	| Node (l, _, r) => size l + 1 + size r
