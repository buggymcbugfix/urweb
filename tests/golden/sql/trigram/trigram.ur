table t : { Id : int, Name : string } PRIMARY KEY Id

ensure_index t : {Name = trigram}

fun main () : transaction page = return <xml/>
