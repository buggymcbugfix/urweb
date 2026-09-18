(* Literals are printed as written. *)
val i = 42
val neg = -42
val f = 3.14
val s = "a string"
val escaped = "quotes \" and backslashes \\ and a newline \n and a tab \t"
val tricky = "(* not a comment *) <xml/> {[not a hole]}"
val empty = ""
val c = #"c"
val c' = #"\n"
val c'' = #"\""
val u = ()
val b = True
val here = _LOC_

(* Long strings do not break. *)
val long = "a string that goes on and on and on and on and on and on and on and on and on and on and on and on"

(* Concatenation, broken by the author. *)
val greeting =
	"Hello, "
		^ name
		^ "!"

(* Strings containing SQL and XML are just strings. *)
val sql = "SELECT * FROM t WHERE t.A = 1"
val html = "<p>text</p>"

(* Numbers in patterns and arithmetic. *)
fun classify n =
	case n of
	| 0 => "zero"
	| 1 => "one"
	| _ => if n < 0 then "negative" else "many"

val arith = (-1) * (2 + -3)
