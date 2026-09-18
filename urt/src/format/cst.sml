(* Concrete syntax tree for Ur/Web, built by the generated grammar (cst.grm).
 *
 * A Node is one grammar alternative: its nonterminal, the alternative's
 * right-hand side spelled out (the "shape"), and its children in grammar
 * order.  A Tok is one terminal: its token kind and its [left, right)
 * character span in the source.  Neither carries text; `Source.text` slices
 * it out of the file, so concatenating the leaves of a tree, with the gaps
 * between them (whitespace and comments: the trivia), reproduces the file
 * byte for byte.
 *)

structure Cst = struct

datatype node =
         Node of {nt : string, shape : string, kids : node list}
       | Tok of {kind : string, left : int, right : int}

fun node (nt, shape, kids) = Node {nt = nt, shape = shape, kids = kids}
fun tok (kind, left, right) = Tok {kind = kind, left = left, right = right}

(* leaves in source order *)
fun tokens n =
    let
        fun go (Tok t, acc) = t :: acc
          | go (Node {kids, ...}, acc) = foldl go acc kids
    in
        rev (go (n, []))
    end

(* first and last token with a non-empty span (the synthetic SIG token of
 * a signature file is empty) *)
fun firstTok n =
    case n of
        Tok (t as {left, right, ...}) => if right > left then SOME t else NONE
      | Node {kids, ...} =>
        let
            fun go [] = NONE
              | go (k :: ks) = case firstTok k of
                                   NONE => go ks
                                 | r => r
        in
            go kids
        end

fun lastTok n =
    case n of
        Tok (t as {left, right, ...}) => if right > left then SOME t else NONE
      | Node {kids, ...} =>
        let
            fun go [] = NONE
              | go (k :: ks) = case lastTok k of
                                   NONE => go ks
                                 | r => r
        in
            go (rev kids)
        end

(* Shape-directed traversal: the number of nodes per shape, for coverage
 * reports. *)
fun countShapes n =
    let
        val tbl = ref ([] : (string * int ref) list)
        fun bump s =
            case List.find (fn (s', _) => s = s') (!tbl) of
                SOME (_, r) => r := !r + 1
              | NONE => tbl := (s, ref 1) :: !tbl
        fun go (Tok _) = ()
          | go (Node {shape, kids, ...}) = (bump shape; app go kids)
    in
        go n;
        map (fn (s, r) => (s, !r)) (!tbl)
    end

(* S-expression dump, for debugging and golden tests *)
fun dump (src : string) n =
    let
        val out = ref ([] : string list)
        fun emit s = out := s :: !out
        fun go ind (Tok {kind, left, right}) =
            emit (ind ^ kind ^ " " ^ String.toString (String.substring (src, left, right - left)) ^ "\n")
          | go ind (Node {shape, kids, ...}) =
            (emit (ind ^ "(" ^ shape ^ "\n");
             app (go (ind ^ "  ")) kids;
             emit (ind ^ ")\n"))
    in
        go "" n;
        String.concat (rev (!out))
    end

end
