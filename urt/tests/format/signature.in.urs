(* Every kind of item a signature can hold. *)

type id = int
type pair a = a * a
type abstract

con fields = [Id = int, Name = string]
con abstractCon :: Type
con abstractRow :: {Type}
con mapped :: {Type} -> {Type} = map option

datatype color = Red | Green | Blue
datatype tree a = Leaf | Node of tree a * a * tree a
datatype shape =
	| Circle of float
	| Square of float
	| Rectangle of float * float
datatype either a b = Left of a | Right of b
datatype option' = datatype Basis.option

val zero : id
val add : int -> int -> int
val show : t ::: Type -> t -> string
val proj : nm :: Name -> t ::: Type -> r ::: {Type} -> [[nm] ~ r] => $([nm = t] ++ r) -> t

val render :
	string ->
	{Id : int, Name : string} ->
	transaction xbody

val complex :
	{
		Id : int,
		Name : string
	}
	-> transaction {}

structure Sub : sig
	val x : int
end

structure Sub' :
	sig
		type t
		val make : int -> t
	end

structure Sealed : SIG where type t = int

functor Make (M : sig type t end) : sig val x : M.t end

functor Make'
	(
		M : sig
			con cols :: {Type}
			val fl : folder cols
		end
	)
	: sig
		val count : int
	end

include COMMON
include sig val included : int end

table tbUser : {Id : int, Name : string}
table tbOrder :
	{
		Id : int,
		UserId : int
	}
	PRIMARY KEY Id
sequence seqOrder
view vwActive : {Id : int, Name : string}
cookie session : string
style highlighted
constraint [A] ~ [B]

class monad :: (Type -> Type) -> Type
class show t = t -> string
class read (t :: Type) = string -> option t
