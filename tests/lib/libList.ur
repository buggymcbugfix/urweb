(* Each new List function at its declared type.  A signature change stops this
case elaborating; what the functions compute is not checked here. *)

fun show_list [t] (_ : show t) : show (list t) =
    mkShow (let
                fun shower (xs : list t) =
                    case xs of
                        [] => "[]"
                      | x :: xs => show x ^ " :: " ^ shower xs
            in
                (fn (xs : list t) => case xs of [] => "[]" | _ => "(" ^ shower xs ^ ")")
            end)

fun show_pair [a ::: Type] [b ::: Type] (_ : show a) (_ : show b) : show (a * b) =
    mkShow (fn (y, z) => "(" ^ show y ^ "," ^ show z ^ ")")

val ints : list int = 1 :: 2 :: 3 :: []
val nested : list (list int) = ints :: ints :: []
val assoc : list (string * int) = ("a", 1) :: ("b", 2) :: []

val a : list int = List.snoc ints 4
val b : list int = List.concat (ints :: a :: [])
val b' : list int = List.concat []
val c : bool = List.any (fn x => x > 2) ints
val d : option int = List.findIndex (fn x => x = 2) ints
val e : list (string * int) = List.assocUpdate "a" (fn v => Some (v + 1)) assoc
val f : list (string * int) = List.assocUpdate "a" (fn _ => None) assoc
val g : list int = List.intersperse 0 ints

val main : transaction page =
    return
        <xml>
            <body>
                <pre>
                val ints : list int = 1 :: 2 :: 3 :: []
                ints = {[ints]}
                </pre>

                <pre>
                val assoc : list (string * int) = ("a", 1) :: ("b", 2) :: []
                assoc = {[assoc]}
                </pre>


                <pre>
                val a : list int = List.snoc ints 4
                a = {[a]}
                </pre>

                <pre>
                val b : list int = List.concat (ints :: a :: [])
                b = {[b]}
                </pre>

                <pre>
                val b' : list int = List.concat []
                b' = {[b']}
                </pre>

                <pre>
                val c : bool = List.any (fn x => x > 2) ints
                c = {[c]}
                </pre>

                <pre>
                val d : option int = List.findIndex (fn x => x = 2) ints
                d = {[d]}
                </pre>

                <pre>
                val e : list (string * int) = List.assocUpdate "a" (fn v => Some (v + 1)) assoc
                e = {[e]}
                </pre>

                <pre>
                val f : list (string * int) = List.assocUpdate "a" (fn _ => None) assoc
                f = {[f]}
                </pre>

                <pre>
                val g : list int = List.intersperse 0 ints
                g = {[g]}
                </pre>
            </body>
        </xml>
