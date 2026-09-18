(* The formatter's own semantic check, run on every invocation: the
 * compiler's parse of the input and of the output must be the same AST.
 *
 * The compiler's grammar and lexer are linked in (ast.grm / ast.lex are
 * renamed copies of src/urweb.grm and src/urweb.lex), so this needs no
 * urweb binary and cannot drift from the grammar the formatter parses with.
 *
 * Two things are allowed to differ and are canonicalised away before the
 * parse: whitespace inside XML text, which the formatter may re-indent
 * (adjacent whitespace is equivalent for a browser; whether there is any
 * whitespace between two nodes is not, and is preserved exactly), and
 * `_LOC_`, whose value is its own position. *)

structure Check : sig
    (* NONE if the two files parse to the same AST, else a message *)
    val same : {name : string, pre : Cst.node * string, post : Cst.node * string} -> string option
    (* the canonical text of a parsed file (for debugging) *)
    val canonical : Cst.node * string -> string
end = struct

structure LrVals = AstLrValsFn(structure Token = LrParser.Token)
structure Lex = AstLexFn(structure Tokens = LrVals.Tokens)
structure P = Join(structure ParserData = LrVals.ParserData
                   structure Lex = Lex
                   structure LrParser = LrParser)

(* elements whose text is whitespace-sensitive in HTML *)
val preformatted = ["pre", "textarea"]

fun collapse s =
    let
        val toks = String.tokens Char.isSpace s
        val lead = size s > 0 andalso Char.isSpace (String.sub (s, 0))
        val trail = size s > 0 andalso Char.isSpace (String.sub (s, size s - 1))
    in
        (if lead then " " else "") ^ String.concatWith " " toks ^ (if trail andalso not (null toks) then " " else "")
    end

(* canonical text: the tokens from the source, with comments removed, XML
 * text whitespace collapsed (outside preformatted elements) and _LOC_
 * replaced by a constant string.  The lexer splits XML text at newlines,
 * and comments split it too; adjacent text tokens are one run of text to
 * a browser, so their whitespace collapses together. *)
fun canonical (cst, src) =
    let
        val out = ref ([] : string list)
        fun emit s = out := s :: !out
        val pos = ref 0
        fun gapTo left =
            let
                val g = Trivia.whitespaceOf (String.substring (src, !pos, left - !pos))
            in
                emit g; pos := left; g = ""
            end
        fun tokText {left, right, ...} = String.substring (src, left, right - left)
        (* the previous token was XML text ending in a space *)
        val prevSpace = ref false
        fun go pre (Cst.Tok (t as {kind, left, right})) =
            let
                val adjacent = gapTo left
            in
                (case kind of
                     "NOTAGS" =>
                     if pre then (emit (tokText t); prevSpace := false)
                     else
                         let
                             val s = collapse (tokText t)
                             val s = if adjacent andalso !prevSpace andalso String.isPrefix " " s
                                     then String.extract (s, 1, NONE) else s
                         in
                             emit s;
                             prevSpace := (String.isSuffix " " s orelse (s = "" andalso adjacent andalso !prevSpace))
                         end
                   | "STRING" => (let val s = tokText t in emit (if s = "_LOC_" then "\"_LOC_\"" else s) end;
                                  prevSpace := false)
                   | _ => (emit (tokText t); prevSpace := false));
                pos := right
            end
          | go pre (Cst.Node {shape = "xmlOne : tag GT xmlOpt END_TAG", kids, ...}) =
            let
                val pre' = pre orelse
                           (case kids of
                                Cst.Node {kids = [Cst.Node {kids = [Cst.Tok t], ...}, _], ...} :: _ =>
                                (case String.tokens (fn c => c = #"<") (tokText t) of
                                     [name] => List.exists (fn p => p = name) preformatted
                                   | _ => false)
                              | _ => false)
            in
                app (go pre') kids
            end
          | go pre (Cst.Node {kids, ...}) = app (go pre) kids
    in
        go false cst;
        emit (String.extract (src, !pos, NONE));
        String.concat (rev (!out))
    end

fun parse name isUrs text =
    let
        val text = if isUrs then "sig\n" ^ text else text
        val () = (ErrorMsg.resetErrors ();
                  ErrorMsg.resetPositioning name;
                  Lex.UserDeclarations.initialize ())
        val pos = ref 0
        fun get n =
            let
                val i = !pos
                val j = Int.min (size text, i + n)
            in
                pos := j;
                String.substring (text, i, j - i)
            end
        fun parseerror (s, p1, p2) = ErrorMsg.errorAt' (p1, p2) s
        val lexer = LrParser.Stream.streamify (Lex.makeLexer get)
        val (absyn, _) = P.parse (30, lexer, parseerror, ())
    in
        SOME (absyn, ErrorMsg.anyErrors ())
    end
    handle LrParser.ParseError => NONE

fun same {name, pre, post} =
    let
        val isUrs = String.isSuffix ".urs" name
        (* the compiler's parser prints its errors; run it quietly *)
        val a = parse name isUrs (canonical pre)
        val b = parse name isUrs (canonical post)
    in
        case (a, b) of
            (NONE, _) => SOME "the compiler's parser rejects the input"
          | (_, NONE) => SOME "the compiler's parser rejects the formatted output"
          | (SOME (fa, ea), SOME (fb, eb)) =>
            if ea <> eb then SOME "the compiler's parser reports errors for one side only"
            else SourceEq.file (fa, fb)
    end

end
