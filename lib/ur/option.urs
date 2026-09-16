datatype t = datatype Basis.option

val monad : monad t

val eq : a ::: Type -> eq a -> eq (t a)
val ord : a ::: Type -> ord a -> ord (t a)

val isNone : a ::: Type -> t a -> bool
val isSome : a ::: Type -> t a -> bool

val mp : a ::: Type -> b ::: Type -> (a -> b) -> t a -> t b
val app : m ::: (Type -> Type) -> a ::: Type -> monad m -> (a -> m {}) -> t a -> m {}
val bind : a ::: Type -> b ::: Type -> (a -> option b) -> t a -> t b

val get : a ::: Type -> a -> option a -> a
(* As unsafeGet, but the caller says what the error should read. *)
val getOrError : a ::: Type -> xbody -> option a -> a
val unsafeGet : a ::: Type -> option a -> a

val mapM : m ::: (Type -> Type) -> monad m -> a ::: Type -> b ::: Type -> (a -> m b) -> t a -> m (t b)

(* The case analysis as a function: the first argument is used for None, the
second applied to the contents of Some. *)
val fold : a ::: Type -> b ::: Type -> b -> (a -> b) -> option a -> b

(* Some () when the condition holds, None otherwise, so that a chain of binds
can give up partway.  This belongs to Alternative rather than to Option, but
Ur/Web has no Alternative. *)
val guard : bool -> t unit
