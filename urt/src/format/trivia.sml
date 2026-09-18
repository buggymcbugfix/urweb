(* Trivia: the text between tokens (whitespace and comments) and how it
 * attaches to tokens.
 *
 * A comment that starts on the same line as the token before it is a
 * *trailing* comment of that token; every other comment is a *leading*
 * comment of the token after it.  Blank lines (two or more newlines) are
 * recorded so that a rule can keep one where the author had one. *)

structure Trivia :> sig
    (* col: the tab depth of the line the comment starts on; joined: no
     * line break between this comment and the previous one of its kind;
     * for a trailing comment, no whitespace at all before it (in XML that
     * distinction is data) *)
    type comment = {text : string, col : int, blankBefore : bool, joined : bool}
    type gap = {trailing : comment list,  (* same line as the previous token *)
                dangling : comment list,  (* on their own lines right after the previous token,
                                           * with a blank line after them: they belong to what precedes *)
                leading : comment list,   (* on their own lines before the next token *)
                blankBefore : bool,       (* blank line before the next token (or its first leading comment) *)
                blankAfterLeading : bool} (* blank line between the last leading comment and the token *)

    (* Analyse the gap text that starts at source offset `start`.  `depthOf`
     * gives the tab depth of the line containing a source offset;
     * `prevKind` is the kind of the previous token, NONE at the start of
     * the file, where nothing precedes a comment that it could trail. *)
    val analyse : (int -> int) -> int -> string option -> string -> gap
    val noGap : gap
    (* just the comments of a gap text, in order *)
    val allComments : string -> comment list
    (* the gap text without its comments *)
    val whitespaceOf : string -> string
end = struct

type comment = {text : string, col : int, blankBefore : bool, joined : bool}
type gap = {trailing : comment list, dangling : comment list, leading : comment list,
            blankBefore : bool, blankAfterLeading : bool}

val noGap = {trailing = [], dangling = [], leading = [], blankBefore = false, blankAfterLeading = false}

datatype item = Ws of string | Cm of int (* offset within gap *) * string

fun items s =
    let
        val n = size s
        fun startsWith (p, i) = String.isPrefix p (String.extract (s, i, NONE))
        (* end of a (* *) comment starting at i, nesting aware *)
        fun mlEnd (i, depth) =
            if i >= n then n
            else if startsWith ("(*", i) then mlEnd (i + 2, depth + 1)
            else if startsWith ("*)", i) then
                (if depth = 1 then i + 2 else mlEnd (i + 2, depth - 1))
            else mlEnd (i + 1, depth)
        fun xmlEnd i =
            if i >= n then n
            else if startsWith ("-->", i) then i + 3
            else xmlEnd (i + 1)
        fun go (i, wsStart, acc) =
            if i >= n then
                rev (if wsStart < n then Ws (String.substring (s, wsStart, n - wsStart)) :: acc else acc)
            else if startsWith ("(*", i) then
                let
                    val j = mlEnd (i, 0)
                    val acc = if wsStart < i then Ws (String.substring (s, wsStart, i - wsStart)) :: acc else acc
                in
                    go (j, j, Cm (i, String.substring (s, i, j - i)) :: acc)
                end
            else if startsWith ("<!--", i) then
                let
                    val j = xmlEnd i
                    val acc = if wsStart < i then Ws (String.substring (s, wsStart, i - wsStart)) :: acc else acc
                in
                    go (j, j, Cm (i, String.substring (s, i, j - i)) :: acc)
                end
            else go (i + 1, wsStart, acc)
    in
        go (0, 0, [])
    end

fun whitespaceOf s =
    String.concat (List.mapPartial (fn Ws w => SOME w | Cm _ => NONE) (items s))

fun allComments s =
    List.mapPartial (fn Cm (_, c) => SOME {text = c, col = 0, blankBefore = false, joined = false} | Ws _ => NONE) (items s)

fun newlines s = CharVector.foldl (fn (#"\n", n) => n + 1 | (_, n) => n) 0 s

(* tokens that open a block: a comment right after them is inside the
 * block, not a note on what came before *)
val openers = ["LET", "IN", "STRUCT", "SIG", "LPAREN", "LBRACE", "LBRACK", "OF", "THEN", "ELSE",
               "DARROW", "EQ", "LARROW", "BAR", "COMMA", "XML_BEGIN", "GT", "BEGIN_TAG", "NOTAGS"]

fun analyse colOf start prevKind s =
    let
        val atStart = not (isSome prevKind)
        val its = items s
        val its = if atStart then Ws "\n" :: its else its
        (* split off trailing comments: those before the first newline *)
        fun trailing (its, glued, acc) =
            case its of
                Cm (off, c) :: rest =>
                trailing (rest, true, {text = c, col = colOf (start + off), blankBefore = false, joined = glued} :: acc)
              | Ws w :: rest =>
                if newlines w > 0 then (rev acc, its) else trailing (rest, false, acc)
              | [] => (rev acc, [])
        val (trailingCs, rest) = trailing (its, true, [])
        (* own-line comments, with blank-line info *)
        fun leading (its, prevWs, acc) =
            case its of
                [] => (rev acc, newlines prevWs >= 2)
              | Ws w :: rest => leading (rest, w, acc)
              | Cm (off, c) :: rest =>
                leading (rest, "",
                         {text = c, col = colOf (start + off), blankBefore = newlines prevWs >= 2,
                          joined = not (null acc) andalso newlines prevWs = 0} :: acc)
        val (ld, blankAfter) = leading (rest, "", [])
        (* comments directly after the previous line, not indented deeper
         * than it, and followed by a blank line belong to what precedes them *)
        val startsWithBlank = case rest of Ws w :: _ => newlines w >= 2 | _ => false
        fun split (cs, acc) =
            case cs of
                [] => (rev acc, [])
              | c :: rest =>
                if #blankBefore c then (rev acc, cs)
                else split (rest, c :: acc)
        val afterOpener = case prevKind of
                              SOME k => List.exists (fn x => x = k) openers
                            | NONE => true
        val (dangling, ld) =
            if atStart orelse startsWithBlank orelse null ld orelse afterOpener then ([], ld)
            else
                let val (d, l) = split (ld, [])
                in
                    (* only if a blank line follows the dangling part *)
                    if null l andalso not blankAfter then ([], ld) else (d, l)
                end
        val ld = case ld of
                     c :: rest => {text = #text c, col = #col c, blankBefore = #blankBefore c orelse not (null dangling), joined = false} :: rest
                   | [] => []
        val blankBefore =
            case ld of
                c :: _ => #blankBefore c
              | [] => (case rest of
                           Ws w :: _ => newlines w >= 2
                         | _ => false) orelse not (null dangling)
    in
        {trailing = trailingCs, dangling = dangling, leading = ld, blankBefore = blankBefore,
         blankAfterLeading = blankAfter andalso not (null ld)}
    end

end
