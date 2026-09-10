(* The CHECK embeds a value the compiler does not fold to a constant, so
   the constraint never becomes a string and cjrize rejects the table. *)
val limit = strlen "abcdefg"

table t : { Id : int, Name : string }
  PRIMARY KEY Id,
  CONSTRAINT C CHECK Id < {[limit]}

fun main () : transaction page = return <xml>{[limit]}</xml>
