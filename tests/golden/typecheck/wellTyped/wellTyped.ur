fun twice [a] (f : a -> a) (x : a) : a = f (f x)

fun main () : transaction page = return <xml><body>{[twice (fn x => x + 1) 40]}</body></xml>
