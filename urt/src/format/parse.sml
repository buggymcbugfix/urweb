(* Lexer/parser wiring, following Compiler.parseUr in the Ur/Web compiler. *)

structure Parse : sig
    (* Parse a whole .ur file. Returns the CST and the source text, or NONE
     * after printing errors (ErrorMsg's usual file:line:col format). *)
    val parseFile : string -> (Cst.node * string) option
    val parseString : string (* filename, for messages *) -> string -> (Cst.node * string) option
    (* text of a file with the given name (a .urs name means a signature) *)
    val parseText : string * string -> (Cst.node * string) option
end = struct

structure LrVals = UrwebLrValsFn(structure Token = LrParser.Token)
structure Lex = UrwebLexFn(structure Tokens = LrVals.Tokens)
structure UrwebP = Join(structure ParserData = LrVals.ParserData
                        structure Lex = Lex
                        structure LrParser = LrParser)

fun parseString filename src =
    let
        val () = (ErrorMsg.resetErrors ();
                  ErrorMsg.resetPositioning filename;
                  Lex.UserDeclarations.initialize ())
        val pos = ref 0
        fun get n =
            let
                val i = !pos
                val j = Int.min (size src, i + n)
            in
                pos := j;
                String.substring (src, i, j - i)
            end
        fun parseerror (s, p1, p2) = ErrorMsg.errorAt' (p1, p2) s
        val lexer = LrParser.Stream.streamify (Lex.makeLexer get)
        val (cst, _) = UrwebP.parse (30, lexer, parseerror, ())
    in
        if ErrorMsg.anyErrors () then NONE else SOME (cst, src)
    end
    handle LrParser.ParseError => NONE

(* A .urs file is parsed the way the compiler does it: with "sig\n" in front,
 * which the lexer recognises (see initialSig in urweb.lex) and compensates
 * for by shifting all later positions back, so token spans index the
 * original text.  The synthetic SIG token is the exception; give it an
 * empty span at 0 so the tree still tiles the original text. *)
fun parseText (filename, src) =
    let
        val isUrs = String.isSuffix ".urs" filename
    in
        if isUrs then
            case parseString filename ("sig\n" ^ src) of
                SOME (Cst.Node {nt = "file", shape, kids = [Cst.Tok {kind = "SIG", ...}, sgis]}, _) =>
                SOME (Cst.Node {nt = "file", shape = shape,
                                kids = [Cst.Tok {kind = "SIG", left = 0, right = 0}, sgis]}, src)
              | SOME _ => raise Fail "parseFile: .urs did not parse as a signature"
              | NONE => NONE
        else
            case parseString filename src of
                SOME (Cst.Node {kids = [Cst.Tok {kind = "SIG", ...}, _], ...}, _) =>
                (ErrorMsg.error "File starts with 'sig'"; NONE)
              | r => r
    end

fun parseFile filename =
    let
        val inf = TextIO.openIn filename
        val src = TextIO.inputAll inf
        val () = TextIO.closeIn inf
    in
        parseText (filename, src)
    end

end
