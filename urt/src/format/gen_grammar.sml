(* Turn the Ur/Web compiler's grammar (src/urweb.grm) into a grammar whose
 * semantic actions build a concrete syntax tree instead of the desugared
 * Source AST.
 *
 * The productions (nonterminal : symbol ... symbol) are copied verbatim, so
 * the generated grammar accepts exactly the language the compiler accepts,
 * with the same precedence declarations and the same conflicts resolved the
 * same way.  Only the actions differ: every alternative builds
 *     Cst.node (nt, shape, children)
 * where `shape` is the alternative's right-hand side spelled out ("eterm :
 * LET edecls IN eexp END"), which is what the printer matches on, and
 * `children` are the values of the nonterminals and the source spans of the
 * terminals, in grammar order.  Terminals carry no text: the printer reads
 * it from the source, which is what makes verbatim reconstruction byte-exact.
 *
 * Usage: gen_grammar URWEB_SRC/urweb.grm > cst.grm *)

structure GenGrammar = struct

fun readFile name =
    let
        val f = TextIO.openIn name
        val s = TextIO.inputAll f
    in
        TextIO.closeIn f; s
    end

fun fail msg = (TextIO.output (TextIO.stdErr, "gen_grammar: " ^ msg ^ "\n");
                OS.Process.exit OS.Process.failure)

fun isIdStart c = Char.isAlpha c orelse c = #"_"
fun isIdChar c = Char.isAlphaNum c orelse c = #"_" orelse c = #"'"

fun startsWith (s, i, p) = String.isPrefix p (String.extract (s, i, NONE))

(* index just past the SML comment starting at i (nesting aware) *)
fun skipComment (s, i) =
    let
        fun go (i, depth) =
            if i >= size s then fail "unterminated comment"
            else if startsWith (s, i, "(*") then go (i + 2, depth + 1)
            else if startsWith (s, i, "*)") then
                (if depth = 1 then i + 2 else go (i + 2, depth - 1))
            else go (i + 1, depth)
    in
        go (i, 0)
    end

(* index just past the string literal whose opening quote is at i *)
fun skipString (s, i) =
    let
        fun go i =
            if i >= size s then fail "unterminated string"
            else case String.sub (s, i) of
                     #"\\" => go (i + 2)
                   | #"\"" => i + 1
                   | _ => go (i + 1)
    in
        go (i + 1)
    end

(* s[i] = "(": index just past the matching ")", skipping strings, char
 * literals and comments *)
fun skipAction (s, i) =
    let
        fun go (i, depth) =
            if i >= size s then fail "unbalanced action"
            else if startsWith (s, i, "(*") then go (skipComment (s, i), depth)
            else if startsWith (s, i, "#\"") then go (skipString (s, i + 1), depth)
            else case String.sub (s, i) of
                     #"\"" => go (skipString (s, i), depth)
                   | #"(" => go (i + 1, depth + 1)
                   | #")" => if depth = 1 then i + 1 else go (i + 1, depth - 1)
                   | _ => go (i + 1, depth)
    in
        go (i, 0)
    end

fun skipWs (s, i) =
    if i >= size s then i
    else if Char.isSpace (String.sub (s, i)) then skipWs (s, i + 1)
    else if startsWith (s, i, "(*") then skipWs (s, skipComment (s, i))
    else i

fun ident (s, i) =
    let
        fun go j = if j < size s andalso isIdChar (String.sub (s, j)) then go (j + 1) else j
    in
        if i < size s andalso isIdStart (String.sub (s, i)) then
            let val j = go (i + 1) in SOME (String.substring (s, i, j - i), j) end
        else NONE
    end

(* the rules section: a list of (nonterminal, rhs symbols), one per alternative *)
fun parseRules body =
    let
        fun rhs (i, acc) =
            let
                val i = skipWs (body, i)
            in
                if i >= size body then fail "rule without action"
                else if String.sub (body, i) = #"(" then (rev acc, skipAction (body, i))
                else case ident (body, i) of
                         SOME (x, j) => rhs (j, x :: acc)
                       | NONE => fail ("unexpected text in rule: " ^ String.substring (body, i, Int.min (40, size body - i)))
            end
        fun rules (i, cur, acc) =
            let
                val i = skipWs (body, i)
            in
                if i >= size body then rev acc
                else if String.sub (body, i) = #"|" then
                    (case cur of
                         NONE => fail "'|' before any rule"
                       | SOME nt =>
                         let val (syms, j) = rhs (i + 1, []) in rules (j, cur, (nt, syms) :: acc) end)
                else case ident (body, i) of
                         SOME (nt, j) =>
                         let
                             val j = skipWs (body, j)
                             val () = if j < size body andalso String.sub (body, j) = #":" then ()
                                      else fail ("expected ':' after " ^ nt)
                             val (syms, k) = rhs (j + 1, [])
                         in
                             rules (k, SOME nt, (nt, syms) :: acc)
                         end
                       | NONE => fail "expected a nonterminal"
            end
    in
        rules (0, NONE, [])
    end

(* remove SML comments from the declarations section *)
fun stripComments s =
    let
        fun go (i, acc) =
            if i >= size s then String.concat (rev acc)
            else if startsWith (s, i, "(*") then go (skipComment (s, i), acc)
            else go (i + 1, str (String.sub (s, i)) :: acc)
    in
        go (0, [])
    end

(* split the declarations section into directives (each starts with % at
 * the beginning of a line) *)
fun directives decls =
    let
        val lines = String.fields (fn c => c = #"\n") decls
        fun go ([], cur, acc) = rev (finish (cur, acc))
          | go (l :: ls, cur, acc) =
            if String.isPrefix "%" l then go (ls, [l], finish (cur, acc))
            else go (ls, l :: cur, acc)
        and finish ([], acc) = acc
          | finish (cur, acc) = String.concatWith "\n" (rev cur) :: acc
    in
        List.filter (fn d => String.isPrefix "%" d) (go (lines, [], []))
    end

fun trim s = Substring.string (Substring.dropr Char.isSpace (Substring.dropl Char.isSpace (Substring.full s)))

(* "%term A | B of t | C" -> [("A", NONE), ("B", SOME "t"), ...] *)
fun alternatives d =
    let
        val body = String.extract (d, size (hd (String.tokens Char.isSpace d)), NONE)
    in
        List.mapPartial (fn alt =>
                            let val alt = trim alt in
                                if alt = "" then NONE
                                else case String.tokens Char.isSpace alt of
                                         name :: "of" :: ty => SOME (name, SOME (String.concatWith " " ty))
                                       | [name] => SOME (name, NONE)
                                       | _ => fail ("cannot parse declaration: " ^ alt)
                            end)
                        (String.fields (fn c => c = #"|") body)
    end

fun main () =
    let
        val src = case CommandLine.arguments () of
                      [f] => readFile f
                    | _ => fail "usage: gen_grammar urweb.grm"
        (* split at lines consisting of %% *)
        val lines = String.fields (fn c => c = #"\n") src
        fun split (ls, cur, acc) =
            case ls of
                [] => rev (String.concatWith "\n" (rev cur) :: acc)
              | l :: ls => if trim l = "%%" then split (ls, [], String.concatWith "\n" (rev cur) :: acc)
                           else split (ls, l :: cur, acc)
        val (decls, body) = case split (lines, [], []) of
                                [_, decls, body] => (decls, body)
                              | parts => fail ("expected two %% separators, found " ^ Int.toString (length parts - 1))
        val ds = map trim (directives (stripComments decls))
        val terms = case List.find (fn d => String.isPrefix "%term" d) ds of
                        SOME d => alternatives d
                      | NONE => fail "no %term"
        val nonterms = case List.find (fn d => String.isPrefix "%nonterm" d) ds of
                           SOME d => map #1 (alternatives d)
                         | NONE => fail "no %nonterm"
        val others = List.filter (fn d => not (String.isPrefix "%term" d orelse String.isPrefix "%nonterm" d
                                              orelse String.isPrefix "%header" d)) ds
        val header = List.filter (fn d => String.isPrefix "%header" d) ds
        val rules = parseRules body
        val isTerm = fn s => List.exists (fn (t, _) => t = s) terms
        val isNonterm = fn s => List.exists (fn n => n = s) nonterms

        val out = TextIO.stdOut
        fun p s = TextIO.output (out, s)

        fun action (nt, syms) =
            let
                val shape = nt ^ " : " ^ String.concatWith " " syms
                (* ml-yacc names the k-th occurrence of S in a right-hand
                 * side S<k>; S1 is always defined *)
                fun kids ([], _, acc) = rev acc
                  | kids (s :: rest, seen, acc) =
                    let
                        val k = 1 + length (List.filter (fn s' => s' = s) seen)
                        val v = s ^ Int.toString k
                        val kid =
                            if isNonterm s then v
                            else if isTerm s then
                                "tok (\"" ^ s ^ "\", " ^ v ^ "left, " ^ v ^ "right)"
                            else fail ("unknown symbol " ^ s ^ " in " ^ shape)
                    in
                        kids (rest, s :: seen, kid :: acc)
                    end
            in
                "node (\"" ^ nt ^ "\", \"" ^ shape ^ "\", [" ^ String.concatWith ", " (kids (syms, [], [])) ^ "])"
            end

        fun pad s n = if size s >= n then s else s ^ CharVector.tabulate (n - size s, fn _ => #" ")
    in
        p "(* GENERATED by gen_grammar from the Ur/Web compiler's urweb.grm.\n";
        p " * Do not edit; regenerate.  Productions and precedences are upstream's,\n";
        p " * only the semantic actions differ: they build a Cst.node. *)\n";
        p "open Cst\n%%\n";
        app (fn d => p (d ^ "\n")) header;
        p "%term\n   ";
        p (String.concatWith "\n | " (map (fn (t, NONE) => t | (t, SOME ty) => t ^ " of " ^ ty) terms));
        p "\n%nonterm\n   ";
        p (String.concatWith "\n | " (map (fn n => n ^ " of Cst.node") nonterms));
        p "\n";
        app (fn d => p (d ^ "\n")) others;
        p "%%\n";
        ignore (foldl (fn ((nt, syms), prev) =>
                          (p ((if prev = nt then "       | " else pad nt 7 ^ ": ")
                              ^ String.concatWith " " syms ^ "\n"
                              ^ CharVector.tabulate (40, fn _ => #" ")
                              ^ "(" ^ action (nt, syms) ^ ")\n");
                           nt))
                      "" rules);
        TextIO.output (TextIO.stdErr,
                       Int.toString (length terms) ^ " terminals, "
                       ^ Int.toString (length nonterms) ^ " nonterminals, "
                       ^ Int.toString (length rules) ^ " alternatives\n")
    end

end

val _ = GenGrammar.main ()
