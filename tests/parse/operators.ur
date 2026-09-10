(* Precedence and associativity, which the parse tree settles: every
   operator comes out as a prefix application of the function it stands
   for, so what grouped with what is there to read. *)

val addMulSub = 1 + 2 * 3 - 4
val grouped = (1 + 2) * (3 - 4)
val subLeft = 1 - 2 - 3
val subRight = 1 - (2 - 3)

val compared = 1 + 1 < 2 * 2
val andOr = True || False && True
val negated = not (True && False)

val concatenated = "a" ^ "b" ^ "c"

fun ap (x : int) (y : int) : int = x + y

val applyFirst = ap 1 2 + 3
val applyLast = ap 1 (2 + 3)

val branch = if 1 < 2 then 3 else 4

fun main () : transaction page = return <xml><body>{[addMulSub]}</body></xml>
