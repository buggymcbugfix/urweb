val bing : {1 : int, 2 : int, A : int} = (1, 2) ++ {A = 3}

con bang = [1, 2, 3]

type bong = $(map (fn _ => unit) [1, 2, 3])

type splish = $(map (fn _ => unit) [1 = {}, 2 = {}, 3 = {}])

val splash : $(map (fn _ => unit) [1 = {}, 2 = {}, 3 = {}]) = ((), (), ())

val splush : variant (map (fn _ => unit) [1, 2, 3, 4, 5]) = make [#4] ()

val splosh : variant [1 = int, 2 = char] = make [#1] 0

val frimm : string * string * char = {1 = "hello", 2 = "world", 3 = #"!"}
