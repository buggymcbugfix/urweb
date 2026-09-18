(* A file comment, kept at the top. *)

(* Doc comment of f, on its own line *)
fun f x = x + 1 (* trailing comment stays on its line *)
(* a note about f, followed by a blank line: it stays with f *)

(** A doc comment with a star of its own. **)
fun g x = x

(* comment inside a let *)
fun h x =
	let
		(* about y *)
		val y = x * 2 (* twice *)
		(* commented-out declaration *)
		(* val z = 3 *)

		(* about w *)
		val w = y
	in
		if w > 0 then (* positive *) w else (* not *) 0
	end

(*
	A multi-line comment,
		with relative indentation,

	and a blank line inside.
*)
fun last () = return ()

(* Two comments (* nested (* deeply *) *) on one line *) (* and another *)
val nested = 1

(* Comments inside records, arguments, sequences and cases. *)
val r =
	{
		A = 1, (* first *)
		(* the second field *)
		B = 2
	}

val applied =
	f
		(* the first argument *)
		1
		2 (* the second *)

fun sequenced () =
	debug "one"; (* after one *)
	(* before two *)
	debug "two";
	return ()

fun branches o =
	case o of
	(* the happy path *)
	| Some n => n (* found *)
	| None => 0 (* nothing *)

(* A comment between the head and the body, and one before `=`. *)
fun commentedHead x (* the argument *) =
	(* the body *)
	x

(* Comments that move with a construct that is re-laid-out. *)
val list = 1 :: (* two *) 2 :: 3 (* three *) :: []

(* A comment on the line of a closing bracket. *)
val bracketed =
	(
		1
			+ 2
	) (* the sum *)

(* the last comment, after the last declaration *)
