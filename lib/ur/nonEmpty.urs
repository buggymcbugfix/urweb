(* A list that is known to have at least one element, for the cases where the
type system should carry that rather than every caller checking.

The implementation calls List, and a library module can only name another when
the program's .urp lists that one first, so a .urp wanting this one needs
`$/list` above `$/nelist`. *)

type t a = {
     First : a,
     Rest : list a
}

(* Converting to and from ordinary lists.  fromList raises an error on an
empty list; fromListResult reports it instead. *)
val toList : a ::: Type -> t a -> list a
val fromList : a ::: Type -> list a -> t a
val fromListResult : a ::: Type -> list a -> result (t a)

(* Causing a side effect for every element *)
val app : m ::: (Type -> Type) -> a ::: Type
          -> monad m -> (a -> m unit) -> t a -> m unit

(** Different forms of mapping *)

val mp : a ::: Type -> b ::: Type -> (a -> b) -> t a -> t b
(* Garden variety *)

val mapi : a ::: Type -> b ::: Type -> (int -> a -> b) -> t a -> t b
(* Passing numeric index within the list *)

val mapM : m ::: (Type -> Type) -> monad m -> a ::: Type -> b ::: Type
           -> (a -> m b) -> t a -> m (t b)
(* With arbitrary monadic side effects *)

val mapX : a ::: Type -> ctx ::: {Unit} -> (a -> xml ctx [] []) -> t a -> xml ctx [] []
(* Producing XML *)

(** Search for elements matching a predicate *)

val mem : a ::: Type -> eq a -> a -> t a -> bool
(* Membership test *)

val exists : a ::: Type -> (a -> bool) -> t a -> bool
(* Garden variety *)

val existsM : m ::: (Type -> Type) -> monad m -> a ::: Type -> (a -> m bool) -> t a -> m bool
(* With arbitrary monadic side effects.  The search stops at the first match. *)

val findM : m ::: (Type -> Type) -> monad m -> a ::: Type -> (a -> m bool) -> t a -> m (option a)
(* Like existsM, but returns the element that was found *)

val search : a ::: Type -> b ::: Type -> (a -> option b) -> t a -> option b

(** Miscellaneous *)

val rev : a ::: Type -> t a -> t a
(* Reversal *)

val snoc : a ::: Type -> t a -> a -> t a
(* Adding an element at the end *)

val sort : a ::: Type -> (a -> a -> bool) (* > predicate *) -> t a -> t a
