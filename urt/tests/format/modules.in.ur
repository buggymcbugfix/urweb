(* Structures: on one line when written so, else `struct` / the
 * declarations one level deeper / `end`, below `=`. *)
structure Empty = struct end

structure Small = struct val x = 1 end

structure Counter = struct
	val start = 0
	fun next n = n + 1
end

structure Counter' =
	struct
		val start = 0

		fun next n = n + 1
	end

(* With a signature, on the line or spanning lines. *)
structure Sealed : COUNTER = struct val start = 0 fun next n = n + 1 end

structure Sealed' : sig val start : int val next : int -> int end = struct
	val start = 0
	fun next n = n + 1
end

structure Sealed'' :
	sig
		val start : int
		val next : int -> int
	end
=
	struct
		val start = 0
		fun next n = n + 1
	end

(* Signatures, with `where`. *)
signature COUNTER = sig val start : int val next : int -> int end

signature COUNTER' =
	sig
		type t
		val start : t
		val next : t -> t
	end

signature INT_COUNTER = COUNTER' where type t = int
signature INT_COUNTER' = COUNTER' where con t = int

(* Functors: the parameter on the line, or in parentheses on their own
 * lines; the body below `=`. *)
functor Make(M : sig type t end) = struct type u = M.t end

functor Make' (M : COUNTER) : COUNTER = struct
	val start = M.start
	val next = M.next
end

functor Make''
	(
		M : sig
			con cols :: {Type}
			val fl : folder cols
		end
	)
	: sig
		val count : int
	end
=
	struct
		val count = 0
	end

(* Functor applications, `open`, and `open` of an anonymous structure. *)
structure Applied = Make'(Counter)
structure Applied' = Make' (Counter)

open Applied
open Applied.Nested
open constraints Applied

open Make
	(
		struct
			type t = int
		end
	)

(* Structure paths in expressions and types. *)
val v = Applied.start + Applied.Nested.deep
type t = Applied.Nested.t

(* Nested structures. *)
structure Outer =
	struct
		structure Inner =
			struct
				val x = 1
			end

		val y = Inner.x
	end

(* Datatypes and exported paths. *)
export Applied
