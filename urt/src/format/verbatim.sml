(* Reprint a CST exactly as it was read: tokens from their spans, and the
 * gaps between them (whitespace, comments) from the source.  Checks that the
 * leaves tile the source in order; if they don't, the grammar's spans are
 * wrong and formatting could drop text, so that is an error. *)

structure Verbatim : sig
    val reprint : string -> Cst.node -> string
    (* the gap before each token, in order, plus the trailing gap *)
    val gaps : string -> Cst.node -> string list
    (* every comment in the file, in order *)
    val comments : string -> Cst.node -> string list
end = struct

fun reprint src cst =
    let
        val toks = Cst.tokens cst
        fun go (_, []) = []
          | go (prev, {kind, left, right} :: rest) =
            if left < prev orelse right < left orelse right > size src then
                raise Fail ("token " ^ kind ^ " out of order at " ^ Int.toString left)
            else
                String.substring (src, prev, left - prev)
                :: String.substring (src, left, right - left)
                :: go (right, rest)
        val pieces = go (0, toks)
        val lastEnd = case rev toks of
                          [] => 0
                        | {right, ...} :: _ => right
    in
        String.concat (pieces @ [String.extract (src, lastEnd, NONE)])
    end

fun gaps src cst =
    let
        val toks = Cst.tokens cst
        fun go (_, []) = []
          | go (prev, {left, right, ...} :: rest) =
            String.substring (src, prev, left - prev) :: go (right, rest)
        val lastEnd = case rev toks of
                          [] => 0
                        | {right, ...} :: _ => right
    in
        go (0, toks) @ [String.extract (src, lastEnd, NONE)]
    end

fun comments src cst =
    List.concat (map (fn g => map #text (Trivia.allComments g)) (gaps src cst))

end
