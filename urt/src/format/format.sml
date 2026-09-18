(* The formatter: layout rules keyed by grammar shape (the right-hand side
 * of a production, as written in cst.grm), producing a Wadler-style
 * document (doc.sml).
 *
 * The style (STYLE.md): one tab per nesting level.  A construct is either
 * on one line or fully broken, each part on its own line one level deeper.
 * The author decides which by writing a line break inside the construct;
 * a construct containing a multi-line part is broken too; and a width
 * limit, if one is set, breaks what is too long.  XML keeps the author's
 * lines and is re-indented by tag nesting; whitespace between XML nodes is
 * never added or removed, only reshaped.
 *
 * Every token is emitted exactly once, and comments travel with the token
 * they attach to (trivia.sml), so nothing the author wrote can be lost.
 * Nodes without a rule are printed as written, re-indented.  The semantic
 * check is separate (check.sml). *)

structure Format : sig
    val width : int ref     (* 0: no limit *)
    val tabwidth : int ref  (* columns per tab: for the width limit and for space-indented input *)
    val format : string -> Cst.node -> string
end = struct

open Doc
infixr 5 ^^

val width = ref 0
val tabwidth = ref 4

fun sp d = text " " ^^ d
fun hasNewline s = CharVector.exists (fn c => c = #"\n") s
fun hasSpace s = CharVector.exists Char.isSpace s
fun countNewlines s = CharVector.foldl (fn (#"\n", n) => n + 1 | (_, n) => n) 0 s
fun spaces n = CharVector.tabulate (Int.max (0, n), fn _ => #" ")
(* whitespace runs as one space: the width of a single-line node as printed *)
fun collapseWs s = String.concatWith " " (String.tokens Char.isSpace s)

(* ---- the token table ------------------------------------------------- *)

structure Tbl = struct
    type t = {src : string,
              toks : {kind : string, left : int, right : int} vector,
              gaps : Trivia.gap vector,   (* gaps.[i] = gap before token i; gaps.[n] = trailing gap *)
              depths : int vector}        (* tab depth of the line token i starts on *)

    fun lineStart src off =
        if off <= 0 then 0
        else if String.sub (src, off - 1) = #"\n" then off
        else lineStart src (off - 1)

    (* indentation of the line containing off: (tabs, alignment spaces) *)
    fun lineIndent src off =
        let
            fun go (i, tabs, spaces) =
                if i < size src then
                    case String.sub (src, i) of
                        #"\t" => go (i + 1, tabs + 1, spaces)
                      | #" " => go (i + 1, tabs, spaces + 1)
                      | _ => (tabs, spaces)
                else (tabs, spaces)
            val (tabs, spaces) = go (lineStart src off, 0, 0)
        in
            (tabs + spaces div (!tabwidth), spaces mod (!tabwidth))
        end

    fun make (src, cst) : t =
        let
            val toks = Vector.fromList (List.filter (fn {left, right, ...} => right > left) (Cst.tokens cst))
            val n = Vector.length toks
            val indents = Vector.tabulate (n, fn i => lineIndent src (#left (Vector.sub (toks, i))))
            fun gapAt i =
                let
                    val start = if i = 0 then 0 else #right (Vector.sub (toks, i - 1))
                    val stop = if i = n then size src else #left (Vector.sub (toks, i))
                    val prevKind = if i = 0 then NONE else SOME (#kind (Vector.sub (toks, i - 1)))
                in
                    Trivia.analyse (#1 o lineIndent src) start prevKind (String.substring (src, start, stop - start))
                end
        in
            {src = src, toks = toks,
             gaps = Vector.tabulate (n + 1, gapAt),
             depths = Vector.map #1 indents}
        end

    fun index ({toks, ...} : t) left =
        let
            fun go (lo, hi) =
                if lo > hi then raise Fail ("no token at " ^ Int.toString left)
                else
                    let
                        val mid = (lo + hi) div 2
                        val l = #left (Vector.sub (toks, mid))
                    in
                        if l = left then mid
                        else if l < left then go (mid + 1, hi)
                        else go (lo, mid - 1)
                    end
        in
            go (0, Vector.length toks - 1)
        end
end

(* ---- trivia ----------------------------------------------------------- *)

fun commentDoc ({text = s, col, ...} : Trivia.comment) = block col s

(* The comments before token i, each on its own line (or joined on one
 * line as in the source), starting on a fresh line.  Emitted once: by the
 * rule for the construct the token starts, before that construct's group,
 * so that a comment cannot force the construct to break; or by the token
 * itself. *)
fun leadingDocs (tbl : Tbl.t) consumed i =
    if Array.sub (consumed, i) then empty
    else
        let
            val () = Array.update (consumed, i, true)
            val {leading, blankAfterLeading, ...} = Vector.sub (#gaps tbl, i)
            val n = length leading
            fun one (k, c) =
                (if k = 0 then hardline else if #blankBefore c then blankline else empty)
                ^^ commentDoc c
                ^^ (if k = n - 1 then (if blankAfterLeading then blankline else hardline)
                    else if #joined (List.nth (leading, k + 1)) then text " "
                    else hardline)
        in
            cat (ListPair.map one (List.tabulate (n, fn k => k), leading))
        end

(* the comments after token i - 1 on its line, glued to it where the
 * source had no whitespace *)
fun trailingDocs (tbl : Tbl.t) i =
    cat (map (fn c => (if #joined c then empty else text " ") ^^ commentDoc c) (#trailing (Vector.sub (#gaps tbl, i))))

(* the comments on their own lines after token i - 1 that belong to what
 * precedes them (Trivia.dangling).  Emitted once, by the outermost
 * construct ending with that token, after its group. *)
fun danglingDocs (tbl : Tbl.t) consumed i =
    if Array.sub (consumed, i) then empty
    else
        (Array.update (consumed, i, true);
         case #dangling (Vector.sub (#gaps tbl, i)) of
             [] => empty
           | cs => cat (map (fn c => (if #joined c then text " " else hardline) ^^ commentDoc c) cs)
                   ^^ blankline)   (* the blank line that made them belong to what precedes *)

fun hasTrivia (tbl : Tbl.t) i =
    not (null (#leading (Vector.sub (#gaps tbl, i))))
    orelse not (null (#trailing (Vector.sub (#gaps tbl, i + 1))))

fun tokText (tbl : Tbl.t) {left, right, ...} = String.substring (#src tbl, left, right - left)

fun tokDoc tbl (consumed, consumedD) (t as {kind, left, right}) =
    let
        val i = Tbl.index tbl left
        val s = tokText tbl t
        val lead = leadingDocs tbl consumed i
        val dang = danglingDocs tbl consumedD (i + 1)
    in
        lead ^^ (if hasNewline s then raw s else text s) ^^ trailingDocs tbl (i + 1) ^^ dang
    end

(* ---- source queries --------------------------------------------------- *)

fun spanOf n =
    case (Cst.firstTok n, Cst.lastTok n) of
        (SOME {left, ...}, SOME {right, ...}) => SOME (left, right)
      | _ => NONE

fun sourceText (tbl : Tbl.t) n =
    case spanOf n of
        SOME (l, r) => String.substring (#src tbl, l, r - l)
      | NONE => ""

fun gapText (tbl : Tbl.t) (a, b) =
    case (Cst.lastTok a, Cst.firstTok b) of
        (SOME {right, ...}, SOME {left, ...}) => if left > right then String.substring (#src tbl, right, left - right) else ""
      | _ => ""

(* does the author break the line between the end of a and the start of b? *)
fun brokenBetween tbl (a, b) = hasNewline (gapText tbl (a, b))

(* between consecutive elements of a list *)
fun brokenList tbl ns =
    case ns of
        a :: (rest as b :: _) => brokenBetween tbl (a, b) orelse brokenList tbl rest
      | _ => false

(* The padding after each name of a list of `name sep ...` items (record
 * fields, case branches; NONE for items of another form) that aligns the
 * separators, for when the list is broken.  The author decides: if any
 * name touches its separator (`A= 1`), no padding, single spaces; else if
 * any is followed by more than one space (`A   = 1`), each name is padded
 * to the width of the widest; else no padding. *)
fun alignment tbl (items : (Cst.node * Cst.node) option list) : string list =
    let
        val pairs = List.mapPartial (fn x => x) items
        val gaps = map (gapText tbl) pairs
        fun spacesOnly g = CharVector.all (fn c => c = #" " orelse c = #"\t") g
        val names = map (fn (n, _) => sourceText tbl n) pairs
        val align = List.all (not o hasNewline) names
                    andalso not (List.exists (fn g => g = "") gaps)
                    andalso List.exists (fn g => size g > 1 andalso spacesOnly g) gaps
        val w = foldl Int.max 0 (map (size o collapseWs) names)
    in
        map (fn NONE => ""
              | SOME (n, _) => if align then spaces (w - size (collapseWs (sourceText tbl n))) else "")
            items
    end

fun blankBefore tbl n =
    case Cst.firstTok n of
        SOME {left, ...} => #blankBefore (Vector.sub (#gaps tbl, Tbl.index tbl left))
      | NONE => false

fun depthOf tbl n =
    case Cst.firstTok n of
        SOME {left, ...} => Vector.sub (#depths tbl, Tbl.index tbl left)
      | NONE => 0

fun isEmptyNode (Cst.Node {kids = [], ...}) = true
  | isEmptyNode _ = false

(* an argument that stays on the head line of a broken application: a
 * single word, e.g. a variable, a literal, `_LOC_`, `[]`, `r.Field` *)
fun atomic tbl n =
    let
        val s = sourceText tbl n
    in
        s <> "" andalso not (hasSpace s)
        andalso not (List.exists (fn c => String.sub (s, 0) = c) [#"(", #"{", #"<"])
    end

(* ---- helpers on the tree ---------------------------------------------- *)

fun shape (Cst.Node {shape, ...}) = shape
  | shape (Cst.Tok {kind, ...}) = kind

fun isTok k (Cst.Tok {kind, ...}) = kind = k
  | isTok _ _ = false

(* right-recursive lists: `nt : x nt | ` *)
fun elems n =
    case n of
        Cst.Node {kids = [], ...} => []
      | Cst.Node {kids = [x as Cst.Node {nt = "eargl", ...}], ...} => elems x
      | Cst.Node {kids = [x as Cst.Node {nt = "cargl", ...}], ...} => elems x
      | Cst.Node {kids = [x], ...} => [x]
      | Cst.Node {kids = [x, rest as Cst.Node {nt = n2, ...}], nt = n1, ...} =>
        if n1 = n2 then x :: elems rest else [x, rest]
      | Cst.Node {kids, ...} => kids
      | t => [t]

(* `nt : x | x SEP nt`, keeping the separators: (elem, sep option) list.
 * A trailing separator (`{A : t,}`) gives a last element with a separator
 * and nothing after it. *)
fun elemsSep n =
    case n of
        Cst.Node {kids = [x], ...} => [(x, NONE)]
      | Cst.Node {kids = [x, sep as Cst.Tok _, rest as Cst.Node {nt = n2, kids, ...}], nt = n1, ...} =>
        if n1 = n2 then (if null kids then [(x, SOME sep)] else (x, SOME sep) :: elemsSep rest)
        else [(x, SOME sep), (rest, NONE)]
      | _ => [(n, NONE)]

(* an element of a comma-separated list *)
datatype item = Elem of Cst.node
              | Field of Cst.node * Cst.node * Cst.node  (* name, `=` or `:`, value *)

fun elemItem (x, sep) = (Elem x, sep)

fun itemNode (Elem x) = x
  | itemNode (Field (p, s, e)) = Cst.node ("_", "field", [p, s, e])

(* ---- the rules --------------------------------------------------------- *)

fun format src cst =
    let
        val tbl = Tbl.make (src, cst)
        val ntoks = Vector.length (#toks tbl)
        val consumed = Array.array (ntoks + 1, false)
        val consumedD = Array.array (ntoks + 2, false)
        (* for each token, the depth of the deepest construct ending with it *)
        val deepest = Array.array (ntoks + 1, 0)
        val () =
            let
                fun walk n =
                    (case (n, Cst.lastTok n) of
                         (Cst.Node _, SOME {left, ...}) =>
                         let val i = Tbl.index tbl left
                         in Array.update (deepest, i, Int.max (Array.sub (deepest, i), depthOf tbl n)) end
                       | _ => ();
                     case n of Cst.Node {kids, ...} => app walk kids | _ => ())
            in
                walk cst
            end
        val leadingDocs = leadingDocs tbl consumed
        val danglingDocs = danglingDocs tbl consumedD
        val tokDoc = tokDoc tbl (consumed, consumedD)
        fun tok (Cst.Tok t) = tokDoc t
          | tok other = raise Fail ("expected a token, got " ^ shape other)
        fun tokIndex (Cst.Tok {left, ...}) = Tbl.index tbl left
          | tokIndex _ = raise Fail "tokIndex"

        (* a line break where the author wrote one, else a soft break *)
        fun sepFor broken = if broken then hardline else line
        fun ssepFor broken = if broken then hardline else softline

        (* declaration-like nodes, one per line, keeping one blank line
         * where the author had one; or separated by sep *)
        fun declsWith sep ns =
            let
                fun go (_, []) = empty
                  | go (first, d :: ds) =
                    (if first then empty
                     else if blankBefore tbl d then blankline
                     else sep)
                    ^^ f d ^^ go (false, ds)
            in
                go (true, ns)
            end

        and decls ns = declsWith hardline ns

        (* `let` decls `in` e `end`, `struct` decls `end`, `sig` items `end`:
         * on one line when the author wrote it so, else the keywords at the
         * construct's level and each section's contents one level deeper,
         * one declaration per line *)
        and keywordBlock (sections : (Cst.node * Cst.node list) list, close) =
            let
                val all = List.concat (map (fn (k, ns) => k :: ns) sections) @ [close]
                val broken = brokenList tbl all
                             orelse List.exists (fn (_, ns) => List.exists (blankBefore tbl) ns) sections
                val sep = sepFor broken
                fun section (k, ns) = tok k ^^ nest 1 (sep ^^ declsWith sep ns)
                fun go [] = empty
                  | go [s] = section s
                  | go (s :: rest) = section s ^^ sep ^^ go rest
            in
                group (go sections ^^ sep ^^ tok close)
            end

        (* `(` body `)`: on one line, or the brackets on their own lines
         * with the body one level deeper *)
        and bracketed (l, body, r) = brackets ([l], body, fn () => f body, [r])

        (* the same with several bracket tokens, `{[` body `]}`, and the
         * body's document built by the caller (in source order: after the
         * opening brackets) *)
        and brackets (ls, body, mk, rs) =
            let
                val broken = brokenBetween tbl (List.last ls, body) orelse brokenBetween tbl (body, List.hd rs)
                val opening = cat (map tok ls)
                val inner = mk ()
            in
                group (opening ^^ nest 1 (ssepFor broken ^^ inner) ^^ ssepFor broken ^^ cat (map tok rs))
            end

        (* `{x, y, z}` with the source's commas: one line, or one element
         * per line one level deeper.  Fields, `A = x`, have their `=` (or
         * `:`) aligned when the list is broken and the author aligned them
         * (see alignment): the padding is a choice on the list's group. *)
        and commaSeparated (l, items, r) =
            let
                val broken = brokenList tbl (l :: map (itemNode o #1) items @ [r])
                val id = newId ()
                val opening = tok l
                val inner = listItems (id, items, broken)
            in
                groupNamed id (opening ^^ nest 1 (ssepFor broken ^^ inner) ^^ ssepFor broken ^^ tok r)
            end

        (* the items of a list, the comma after each, one per line when
         * broken; the padding of fields shows when the group named id is
         * broken *)
        and listItems (id, items, broken) =
            let
                val pads = alignment tbl (map (fn (Field (p, s, _), _) => SOME (p, s) | _ => NONE) items)
                fun go [] = empty
                  | go (((it, sep), pad) :: rest) =
                    (case it of
                         Elem x => f x
                       | Field (p, s, e) => fWith (itemNode it) (fn () => group (f p ^^ padded id pad ^^ tok s ^^ body (s, e))))
                    ^^ (case sep of SOME c => tok c | NONE => empty)
                    ^^ (case rest of [] => empty | _ => sepFor broken ^^ go rest)
            in
                go (ListPair.zip (items, pads))
            end

        (* the space before a `=`, padded when the named group is broken *)
        and padded id pad = if pad = "" then text " " else ifBreakOf id (text (pad ^ " ")) (text " ")

        (* The head of a declaration, `fun name p1 p2 : t =`.  Broken by the
         * author (a line break between its parts): `fun name`, then the
         * parameters one per line one level deeper, then `: t` (or `:` and
         * the type a level deeper when it spans lines), then `=` at the
         * head's level.  A multi-line type alone keeps the parameters on
         * the head's line: `fun name p1 p2 :` / the type / `=`. *)
        and header (kws, name, params, copt, eq) =
            let
                val (colon, typ) = case copt of
                                       Cst.Node {shape = "copt : COLON cexp", kids = [c, t], ...} => (SOME c, SOME t)
                                     | _ => (NONE, NONE)
                val pieces = name :: params @ (case colon of SOME c => [c] | NONE => [])
                val authorBroken = brokenList tbl pieces
                val typeDoc = Option.map f typ
                val typeBroken = (case typeDoc of SOME d => forced d | NONE => false)
                                 orelse (case (colon, typ) of
                                             (SOME c, SOME t) => brokenBetween tbl (c, t)
                                           | _ => false)
                val head = cat (map (fn k => tok k ^^ text " ") kws) ^^ f name
                fun annotation brk =
                    case (colon, typeDoc) of
                        (SOME c, SOME d) =>
                        brk ^^ group (tok c ^^ nest 1 ((if typeBroken then hardline else line) ^^ d))
                      | _ => empty
            in
                if authorBroken then
                    head ^^ nest 1 (cat (map (fn p => hardline ^^ f p) params) ^^ annotation hardline)
                    ^^ hardline ^^ tok eq
                else if typeBroken then
                    group (head ^^ nest 1 (cat (map (fn p => line ^^ f p) params)))
                    ^^ (case (colon, typeDoc) of
                            (SOME c, SOME d) => sp (tok c) ^^ nest 1 (hardline ^^ d)
                          | _ => empty)
                    ^^ hardline ^^ tok eq
                else
                    group (head ^^ nest 1 (cat (map (fn p => line ^^ f p) params) ^^ annotation line)
                           ^^ ifBreak (hardline ^^ tok eq) (sp (tok eq)))
            end

        (* `... =` then the body: on the line, or one level deeper *)
        and body (eq, e) = nest 1 (sepFor (brokenBetween tbl (eq, e)) ^^ f e)

        (* `fn a b => e`: the parameters on the line, or, when the author
         * broke between them, one per line one level deeper with `=>` back
         * at the level of `fn`; the body on the line or one level deeper *)
        and lambda (fn_, params, d, e) =
            if brokenList tbl (fn_ :: params @ [d]) then
                tok fn_ ^^ nest 1 (cat (map (fn a => hardline ^^ f a) params)) ^^ hardline ^^ tok d ^^ bodyAlone (d, e)
            else
                group (tok fn_ ^^ cat (map (fn a => sp (f a)) params) ^^ sp (tok d) ^^ body (d, e))

        (* the same outside a group: on the line unless the author broke
         * there or the body spans lines *)
        and bodyAlone (eq, e) =
            let
                val d = f e
            in
                nest 1 ((if brokenBetween tbl (eq, e) orelse forced d then hardline else text " ") ^^ d)
            end

        (* an application: head, then the leading single-word arguments the
         * author kept on the head's line, then the rest one per line one
         * level deeper *)
        and application (h, xs) =
            let
                val broken = brokenList tbl (h :: xs)
                fun lead (prev, a :: rest) =
                    if atomic tbl a andalso not (isTok "BANG" a) andalso not (brokenBetween tbl (prev, a)) then
                        let val (l, r) = lead (a, rest) in (a :: l, r) end
                    else ([], a :: rest)
                  | lead (_, []) = ([], [])
                val (leading, rest) = lead (h, xs)
                fun arg a = if isTok "BANG" a then sp (f a) else sepFor broken ^^ f a
            in
                group (f h ^^ cat (map (fn a => sp (f a)) leading) ^^ nest 1 (cat (map arg rest)))
            end

        (* a chain of one binary operator, `a op b op c`; broken, either
         * `a` / `op b` / `op c` one level deeper, or (opAlone) the
         * operators at the chain's level with the operands one deeper.  An
         * operand that spans lines goes below its operator, one deeper. *)
        and chain (ops, operands, opAlone) =
            let
                val broken = brokenList tbl operands
                val brk = sepFor broken
                val sbrk = ssepFor broken
                val first = f (hd operands)
            in
                if opAlone then
                    group (nest 1 (sbrk ^^ first)
                           ^^ cat (ListPair.map (fn (opr, x) => brk ^^ tok opr ^^ nest 1 (brk ^^ f x)) (ops, tl operands)))
                else
                    group (first ^^ nest 1 (cat (ListPair.map (fn (opr, x) => brk ^^ leading (opr, x)) (ops, tl operands))))
            end

        (* `op x`, or `op` / x one level deeper when x spans lines *)
        and leading (opr, x) =
            let
                val opDoc = tok opr
                val d = f x
            in
                opDoc ^^ (if forced d then nest 1 (hardline ^^ d) else sp d)
            end

        (* flatten `x OP (y OP z)` / `(x OP y) OP z` into operands and operators *)
        and flattenChain (node, opKind) =
            case node of
                Cst.Node {kids = [a, opr as Cst.Tok {kind, ...}, b], ...} =>
                if kind = opKind then
                    let
                        val (as1, os1) = flattenChain (a, opKind)
                        val (as2, os2) = flattenChain (b, opKind)
                    in
                        (as1 @ as2, os1 @ [opr] @ os2)
                    end
                else ([node], [])
              | _ => ([node], [])

        and binop opAlone node =
            case node of
                Cst.Node {kids = [_, Cst.Tok {kind, ...}, _], ...} =>
                let val (operands, ops) = flattenChain (node, kind) in chain (ops, operands, opAlone) end
              | _ => asWritten node

        (* `a -> b -> c` in types: components at one level, arrows trailing *)
        and arrows node =
            let
                fun parts n =
                    case n of
                        Cst.Node {shape = "cexp : cexp ARROW cexp", kids = [a, ar, b], ...} => (a, SOME ar) :: parts b
                      | Cst.Node {shape = "cexp : SYMBOL kcolon kind ARROW cexp", kids = [x, k, kd, ar, b], ...} =>
                        (Cst.node ("_", "kbind", [x, k, kd]), SOME ar) :: parts b
                      | Cst.Node {shape = "cexp : LBRACK cexp TWIDDLE cexp RBRACK DARROW cexp", kids = [l, a, t, b, r, ar, c], ...} =>
                        (Cst.node ("_", "disj", [l, a, t, b, r]), SOME ar) :: parts c
                      | Cst.Node {shape = "cexp : CSYMBOL KARROW cexp", kids = [x, ar, b], ...} => (x, SOME ar) :: parts b
                      | Cst.Node {shape = "cexp : CSYMBOL DKARROW cexp", kids = [x, ar, b], ...} => (x, SOME ar) :: parts b
                      | last => [(last, NONE)]
                val ps = parts node
                val broken = brokenList tbl (map #1 ps)
                fun go [] = empty
                  | go [(x, _)] = f x
                  | go ((x, SOME ar) :: rest) = f x ^^ sp (tok ar) ^^ sepFor broken ^^ go rest
                  | go ((x, NONE) :: rest) = f x ^^ go rest
            in
                group (go ps)
            end

        (* `case e of` with the branches at the same level, each `| p =>`,
         * and a body that does not fit on the branch line one level deeper.
         * The `=>` are aligned when the author aligned them (alignment). *)
        and caseExp (c, e, of_, b0, b1, bs) =
            let
                fun branches n =
                    case n of
                        Cst.Node {shape = "branchs : BAR branch branchs", kids = [bar, b, rest], ...} => (SOME bar, b) :: branches rest
                      | _ => []
                val brs = (NONE, b1) :: branches bs
                val bar0 = case b0 of Cst.Node {kids = [bar], ...} => SOME bar | _ => NONE
                val broken = brokenList tbl (of_ :: map #2 brs)
                             orelse (case bar0 of SOME b => hasTrivia tbl (tokIndex b) | NONE => false)
                val brk = sepFor broken
                fun parts br =
                    case br of
                        Cst.Node {shape = "branch : pat DARROW eexp", kids = [p, d, e], ...} => SOME (p, d, e)
                      | _ => NONE
                val id = newId ()
                val pads = alignment tbl (map (fn (_, br) => Option.map (fn (p, d, _) => (p, d)) (parts br)) brs)
                fun one ((bar, br), pad) =
                    brk ^^ (case bar of
                                SOME b => tok b ^^ text " "
                              | NONE => (case bar0 of
                                             SOME b => ifBreak (tok b ^^ text " ") empty
                                           | NONE => ifBreak (text "| ") empty))
                    ^^ (case parts br of
                            SOME (p, d, e) => fWith br (fn () => group (f p ^^ padded id pad ^^ tok d ^^ body (d, e)))
                          | NONE => f br)
                fun go [] = empty
                  | go (x :: rest) = one x ^^ go rest
            in
                groupNamed id (tok c ^^ sp (f e) ^^ sp (tok of_) ^^ go (ListPair.zip (brs, pads)))
            end

        (* `if c then a else b`, with `else if` chains at one level, broken
         * as a whole when any link is; a condition that spans lines goes
         * below `if`, one level deeper, with `then` back at the level of `if` *)
        and ifExp (i, c, t, a, e, b) = ifChain (i, c, t, a, e, b, false)

        and ifChain (i, c, t, a, e, b, outerBroken) =
            let
                val broken = outerBroken orelse brokenList tbl [i, c, t, a, e, b]
                val brk = sepFor broken
                val ifDoc = tok i
                val cDoc = f c
                val condition =
                    if forced cDoc orelse brokenBetween tbl (i, c) then nest 1 (hardline ^^ cDoc) ^^ hardline ^^ tok t
                    else sp cDoc ^^ sp (tok t)
                val thenDoc = nest 1 (brk ^^ f a) ^^ brk ^^ tok e
                val elseDoc =
                    case b of
                        Cst.Node {shape = "eexp : IF eexp THEN eexp ELSE eexp", kids = [i', c', t', a', e', b'], ...} =>
                        sp (ifChain (i', c', t', a', e', b', broken))
                      | Cst.Node {shape = "sqlexp : CIF sqlexp CTHEN sqlexp CELSE sqlexp", kids = [i', c', t', a', e', b'], ...} =>
                        sp (ifChain (i', c', t', a', e', b', broken))
                      | _ => nest 1 (brk ^^ f b)
            in
                group (ifDoc ^^ condition ^^ thenDoc ^^ elseDoc)
            end

        (* `a; b; c`: one statement per line when broken, keeping one blank
         * line where the author had one *)
        and sequence node =
            let
                fun stmts n =
                    case n of
                        Cst.Node {shape = "eexp : bind SEMI eexp", kids = [b, s, e], ...} => (b, SOME s) :: stmts e
                      | last => [(last, NONE)]
                val ss = stmts node
                val broken = brokenList tbl (map #1 ss)
                fun sepBefore x = if broken andalso blankBefore tbl x then blankline else sepFor broken
                fun go [] = empty
                  | go [(x, _)] = f x
                  | go ((x, SOME s) :: (rest as (y, _) :: _)) = f x ^^ tok s ^^ sepBefore y ^^ go rest
                  | go ((x, _) :: rest) = f x ^^ go rest
            in
                group (go ss)
            end

        (* the comments before a construct come before its group, the
         * dangling ones after it come after *)
        and f (node : Cst.node) : doc = fWith node (fn () => rule node)

        (* likewise, around a document built by the caller *)
        and fWith (node : Cst.node) (mk : unit -> doc) : doc =
            let
                val lead = case Cst.firstTok node of
                               SOME {left, ...} => leadingDocs (Tbl.index tbl left)
                             | NONE => empty
                (* the outermost construct at least as deep as the comment,
                 * or as deep as any construct ending here gets *)
                val dang = case Cst.lastTok node of
                               SOME {left, ...} =>
                               let
                                   val t = Tbl.index tbl left
                               in
                                   case #dangling (Vector.sub (#gaps tbl, t + 1)) of
                                       c :: _ => if depthOf tbl node >= Int.min (#col c, Array.sub (deepest, t))
                                                 then danglingDocs (t + 1) else empty
                                     | [] => empty
                               end
                             | NONE => empty
                val d = mk ()
            in
                lead ^^ d ^^ dang
            end

        and rule (node : Cst.node) : doc =
            case node of
                Cst.Tok t => tokDoc t
              | Cst.Node {shape, kids, ...} =>
                case (shape, kids) of
                    ("file : decls", [ds]) => decls (elems ds)
                  | ("file : SIG sgis", [_, ss]) => decls (elems ss)

                  (* declarations *)
                  | ("decl : VAL pat eargl2 copt EQ eexp", [v, p, as_, co, eq, e]) =>
                    group (header ([v], p, elems as_, co, eq) ^^ body (eq, e))
                  | ("decl : VAL REC valis", [v, r, vs]) => tok v ^^ sp (tok r) ^^ text " " ^^ valis vs
                  | ("decl : FUN valis", [fn_, vs]) => tok fn_ ^^ text " " ^^ valis vs
                  | ("edecl : VAL pat EQ eexp", [v, p, eq, e]) =>
                    group (header ([v], p, [], Cst.node ("copt", "copt : ", []), eq) ^^ body (eq, e))
                  | ("edecl : VAL REC valis", [v, r, vs]) => tok v ^^ sp (tok r) ^^ text " " ^^ valis vs
                  | ("edecl : FUN valis", [fn_, vs]) => tok fn_ ^^ text " " ^^ valis vs
                  | ("vali : SYMBOL eargl2 copt EQ eexp", [x, as_, co, eq, e]) =>
                    group (header ([], x, elems as_, co, eq) ^^ body (eq, e))
                  | ("copt : COLON cexp", [c, t]) => sp (tok c) ^^ sp (f t)
                  | ("copt : ", []) => empty

                  | ("decl : CON SYMBOL cargl2 kopt EQ cexp", [c, x, as_, k, eq, t]) =>
                    group (tok c ^^ sp (tok x) ^^ cat (map (fn a => sp (f a)) (elems as_)) ^^ f k ^^ sp (tok eq) ^^ body (eq, t))
                  | ("decl : LTYPE SYMBOL cargl2 EQ cexp", [c, x, as_, eq, t]) =>
                    group (tok c ^^ sp (tok x) ^^ cat (map (fn a => sp (f a)) (elems as_)) ^^ sp (tok eq) ^^ body (eq, t))
                  | ("sgi : CON SYMBOL cargl2 kopt cexpO", [c, x, as_, k, t]) =>
                    tok c ^^ sp (tok x) ^^ cat (map (fn a => sp (f a)) (elems as_)) ^^ f k ^^ f t
                  | ("sgi : LTYPE SYMBOL cargl2 cexpO", [c, x, as_, t]) =>
                    tok c ^^ sp (tok x) ^^ cat (map (fn a => sp (f a)) (elems as_)) ^^ f t
                  | ("cexpO : EQ cexp", [eq, t]) => group (sp (tok eq) ^^ body (eq, t))
                  | ("cexpO : ", []) => empty
                  | ("kopt : DCOLON kind", [c, k]) => sp (tok c) ^^ sp (f k)
                  | ("kopt : ", []) => empty
                  | ("sgi : VAL SYMBOL COLON cexp", [v, x, c, t]) =>
                    group (tok v ^^ sp (tok x) ^^ sp (tok c) ^^ body (c, t))
                  | ("decl : DATATYPE dtypes", [d, ts]) => tok d ^^ text " " ^^ datatypes ts
                  | ("dcon : CSYMBOL OF cexp", [c, of_, t]) => group (tok c ^^ sp (tok of_) ^^ body (of_, t))
                  | ("sgi : DATATYPE dtypes", [d, ts]) => tok d ^^ text " " ^^ datatypes ts
                  | ("decl : TABLE SYMBOL COLON cterm pkopt commaOpt cstopt", [t, x, c, ty, pk, comma, cst]) =>
                    tableDecl (t, x, c, ty, pk, comma, cst)
                  | ("sgi : TABLE SYMBOL COLON cterm pkopt commaOpt cstopt", [t, x, c, ty, pk, comma, cst]) =>
                    tableDecl (t, x, c, ty, pk, comma, cst)
                  | ("decl : COOKIE SYMBOL COLON cexp", [k, x, c, t]) =>
                    group (tok k ^^ sp (tok x) ^^ sp (tok c) ^^ body (c, t))
                  | ("sgi : COOKIE SYMBOL COLON cexp", [k, x, c, t]) =>
                    group (tok k ^^ sp (tok x) ^^ sp (tok c) ^^ body (c, t))
                  | ("sgi : VIEW SYMBOL COLON cexp", [k, x, c, t]) =>
                    group (tok k ^^ sp (tok x) ^^ sp (tok c) ^^ body (c, t))
                  | ("decl : VIEW SYMBOL EQ query", [v, x, eq, q]) =>
                    group (tok v ^^ sp (tok x) ^^ sp (tok eq) ^^ body (eq, q))
                  | ("decl : TASK eapps EQ eexp", [t, e1, eq, e2]) =>
                    group (tok t ^^ sp (f e1) ^^ sp (tok eq) ^^ body (eq, e2))
                  | ("decl : POLICY eexp", [p, e]) => group (tok p ^^ body (p, e))
                  | ("decl : CONSTRAINT cterm TWIDDLE cterm", [k, a, t, b]) => tok k ^^ sp (f a) ^^ sp (tok t) ^^ sp (f b)
                  | ("sgi : CONSTRAINT cterm TWIDDLE cterm", [k, a, t, b]) => tok k ^^ sp (f a) ^^ sp (tok t) ^^ sp (f b)

                  | ("decl : STRUCTURE CSYMBOL EQ str", [s, x, eq, st]) =>
                    group (tok s ^^ sp (tok x) ^^ sp (tok eq) ^^ body (eq, st))
                  | ("decl : STRUCTURE CSYMBOL COLON sgn EQ str", [s, x, c, sg, eq, st]) =>
                    (* a signature that spans lines goes below the colon, one
                     * level deeper, with `=` back at the level of the keyword *)
                    let
                        val head = tok s ^^ sp (tok x) ^^ sp (tok c)
                        val sgDoc = f sg
                    in
                        if forced sgDoc orelse brokenBetween tbl (c, sg) then
                            head ^^ nest 1 (hardline ^^ sgDoc) ^^ hardline ^^ tok eq ^^ bodyAlone (eq, st)
                        else
                            group (head ^^ sp sgDoc ^^ sp (tok eq) ^^ body (eq, st))
                    end
                  | ("decl : SIGNATURE CSYMBOL EQ sgn", [s, x, eq, sg]) =>
                    group (tok s ^^ sp (tok x) ^^ sp (tok eq) ^^ body (eq, sg))
                  | ("sgi : SIGNATURE CSYMBOL EQ sgn", [s, x, eq, sg]) =>
                    group (tok s ^^ sp (tok x) ^^ sp (tok eq) ^^ body (eq, sg))
                  | ("sgi : STRUCTURE CSYMBOL COLON sgn", [s, x, c, sg]) =>
                    group (tok s ^^ sp (tok x) ^^ sp (tok c) ^^ body (c, sg))
                  | ("decl : FUNCTOR CSYMBOL LPAREN CSYMBOL COLON sgn RPAREN EQ str", [k, x, l, m, c, sg, r, eq, st]) =>
                    group (functorHead (k, x, l, m, c, sg, r, NONE) ^^ ifBreak (hardline ^^ tok eq) (sp (tok eq)))
                    ^^ bodyAlone (eq, st)
                  | ("decl : FUNCTOR CSYMBOL LPAREN CSYMBOL COLON sgn RPAREN COLON sgn EQ str", [k, x, l, m, c, sg, r, c2, sg2, eq, st]) =>
                    group (functorHead (k, x, l, m, c, sg, r, SOME (c2, sg2)) ^^ ifBreak (hardline ^^ tok eq) (sp (tok eq)))
                    ^^ bodyAlone (eq, st)
                  | ("sgi : FUNCTOR CSYMBOL LPAREN CSYMBOL COLON sgn RPAREN COLON sgn", [k, x, l, m, c, sg, r, c2, sg2]) =>
                    group (functorHead (k, x, l, m, c, sg, r, SOME (c2, sg2)))
                  | ("decl : OPEN mpath LPAREN str RPAREN", [op_, m, l, st, r]) =>
                    group (tok op_ ^^ sp (f m) ^^ nest 1 (sepFor (brokenBetween tbl (m, l)) ^^ bracketed (l, st, r)))
                  | ("str : STRUCT decls END", [s, ds, e]) => keywordBlock ([(s, elems ds)], e)
                  | ("sgntm : SIG sgis END", [s, ss, e]) => keywordBlock ([(s, elems ss)], e)
                  | ("str : spath LPAREN str RPAREN", [p, l, st, r]) =>
                    group (f p ^^ nest 1 (sepFor (brokenBetween tbl (p, l)) ^^ bracketed (l, st, r)))
                  | ("sgn : sgntm", [x]) => f x
                  | ("sgntm : LPAREN sgn RPAREN", [l, s, r]) => bracketed (l, s, r)
                  | ("sgi : INCLUDE sgn", [i, s]) => tok i ^^ sp (f s)

                  (* expressions *)
                  | ("eexp : eapps", [x]) => f x
                  | ("eapps : eterm", [x]) => f x
                  | ("eapps : eapps eterm", _) => let val (h, xs) = appChain node in application (h, xs) end
                  | ("eapps : eapps LBRACK cexp RBRACK", _) => let val (h, xs) = appChain node in application (h, xs) end
                  | ("eapps : eapps BANG", _) => let val (h, xs) = appChain node in application (h, xs) end
                  | ("capp", [l, c, r]) => bracketed (l, c, r)
                  | ("eterm : LPAREN eexp RPAREN", [l, e, r]) => bracketed (l, e, r)
                  | ("eterm : LPAREN etuple RPAREN", [l, es, r]) => commaSeparated (l, map elemItem (elemsSep es), r)
                  | ("eterm : LBRACE rexp RBRACE", [l, es, r]) => commaSeparated (l, fields es, r)
                  | ("eterm : LET edecls IN eexp END", [l, ds, i, e, en]) => keywordBlock ([(l, elems ds), (i, [e])], en)
                  | ("eexp : CASE eexp OF barOpt branch branchs", [c, e, of_, b0, b1, bs]) => caseExp (c, e, of_, b0, b1, bs)
                  | ("branch : pat DARROW eexp", [p, d, e]) => group (f p ^^ sp (tok d) ^^ body (d, e))
                  | ("eexp : IF eexp THEN eexp ELSE eexp", [i, c, t, a, e, b]) => ifExp (i, c, t, a, e, b)
                  | ("eexp : bind SEMI eexp", _) => sequence node
                  | ("bind : eapps LARROW eapps", [p, a, e]) => group (f p ^^ sp (tok a) ^^ body (a, e))
                  | ("bind : eapps", [e]) => f e
                  | ("eexp : FN eargs DARROW eexp", [fn_, as_, d, e]) => lambda (fn_, elems as_, d, e)
                  | ("eexp : CSYMBOL DKARROW eexp", [x, d, e]) => group (tok x ^^ sp (tok d) ^^ body (d, e))
                  | ("eexp : eexp COLON cexp", [e, c, t]) => f e ^^ sp (tok c) ^^ sp (f t)
                  | ("eexp : eapps DCOLON eexp", _) => binop true node
                  | ("eexp : eexp PLUSPLUS eexp", _) => binop false node
                  | ("eexp : eexp CARET eexp", _) => binop false node
                  | ("eexp : eexp ANDALSO eexp", _) => binop false node
                  | ("eexp : eexp ORELSE eexp", _) => binop false node
                  | ("eexp : eexp EQ eexp", _) => binop false node
                  | ("eexp : eexp NE eexp", _) => binop false node
                  | ("eexp : eexp LT eexp", _) => binop false node
                  | ("eexp : eexp LE eexp", _) => binop false node
                  | ("eexp : eexp GT eexp", _) => binop false node
                  | ("eexp : eexp GE eexp", _) => binop false node
                  | ("eexp : eexp PLUS eexp", _) => binop false node
                  | ("eexp : eexp MINUS eexp", _) => binop false node
                  | ("eexp : eexp DIVIDE eexp", _) => binop false node
                  | ("eexp : eexp MOD eexp", _) => binop false node
                  | ("eexp : eexp FWDAPP eexp", _) => binop false node
                  | ("eexp : eexp REVAPP eexp", _) => binop false node
                  | ("eexp : eexp COMPOSE eexp", _) => binop false node
                  | ("eexp : eexp ANDTHEN eexp", _) => binop false node
                  | ("eexp : eexp BACKTICK_PATH eexp", _) => binop false node
                  | ("eexp : eapps STAR eexp", _) => binop false node
                  | ("eexp : eexp MINUSMINUS cexp", _) => binop false node
                  | ("eexp : eexp MINUSMINUSMINUS cexp", _) => binop false node

                  (* types *)
                  | ("cexp : capps", [x]) => f x
                  | ("capps : cterm", [x]) => f x
                  | ("capps : capps cterm", _) => let val (h, xs) = cappChain node in application (h, xs) end
                  | ("cexp : cexp ARROW cexp", _) => arrows node
                  | ("cexp : SYMBOL kcolon kind ARROW cexp", _) => arrows node
                  | ("cexp : LBRACK cexp TWIDDLE cexp RBRACK DARROW cexp", _) => arrows node
                  | ("cexp : CSYMBOL KARROW cexp", _) => arrows node
                  | ("cexp : CSYMBOL DKARROW cexp", _) => arrows node
                  | ("kbind", [x, k, kd]) => tok x ^^ sp (f k) ^^ sp (f kd)
                  | ("disj", [l, a, t, b, r]) => tok l ^^ f a ^^ sp (tok t) ^^ sp (f b) ^^ tok r
                  | ("cexp : cexp PLUSPLUS cexp", _) => binop false node
                  | ("cexp : FN cargs DARROW cexp", [fn_, as_, d, t]) => lambda (fn_, elems as_, d, t)
                  | ("cexp : LPAREN cexp RPAREN DCOLON kind", [l, t, r, c, k]) => bracketed (l, t, r) ^^ sp (tok c) ^^ sp (f k)
                  | ("cterm : LPAREN ctuplev RPAREN", [l, ts, r]) => commaSeparated (l, map elemItem (elemsSep ts), r)
                  | ("cterm : LPAREN cexp RPAREN", [l, t, r]) => bracketed (l, t, r)
                  | ("cterm : LBRACK rcon RBRACK", [l, fs, r]) => commaSeparated (l, tfields fs, r)
                  | ("cterm : LBRACK rconn RBRACK", [l, fs, r]) => commaSeparated (l, map elemItem (elemsSep fs), r)
                  | ("cterm : LBRACE rcone RBRACE", [l, fs, r]) => commaSeparated (l, tfields fs, r)
                  | ("cterm : DOLLAR cterm", [d, t]) => tok d ^^ f t

                  (* XML *)
                  | ("eterm : XML_BEGIN xml XML_END", [b, x, e]) => xmlLiteral (b, x, e)
                  | ("attr : SYMBOL EQ attrv", [a, eq, v]) => tok a ^^ tok eq ^^ f v
                  | ("earga : LBRACK cexp RBRACK", [l, c, r]) => bracketed (l, c, r)
                  | ("earga : LBRACK cexp TWIDDLE cexp RBRACK", [l, a, t, b, r]) => tok l ^^ f a ^^ sp (tok t) ^^ sp (f b) ^^ tok r
                  | ("pterm : LPAREN pat RPAREN", [l, p, r]) => bracketed (l, p, r)
                  | ("patS : patS COLON cexp", [p, c, t]) => group (f p ^^ sp (tok c) ^^ body (c, t))
                  | ("eargs : earg", [x]) => f x
                  | ("earg : patS", [x]) => f x
                  | ("earg : earga", [x]) => f x
                  | ("eargp : pterm", [x]) => f x
                  | ("eargp : earga", [x]) => f x
                  | ("pat : patS", [x]) => f x
                  | ("patS : pterm", [x]) => f x
                  | ("attrv : LBRACE eexp RBRACE", [l, e, r]) => bracketed (l, e, r)
                  | ("kopt : DCOLONWILD", [t]) => sp (tok t)

                  (* SQL: queries and DML in expressions *)
                  | ("eterm : LPAREN query RPAREN", [l, q, r]) => bracketed (l, q, r)
                  | ("eterm : LPAREN CWHERE sqlexp RPAREN", [l, w, c, r]) =>
                    brackets ([l], stmtNode [w, c], fn () => clauseExpr ([w], c, fn () => condition c), [r])
                  | ("eterm : LPAREN SQL sqlexp RPAREN", [l, s, c, r]) =>
                    brackets ([l], stmtNode [s, c], fn () => clauseExpr ([s], c, fn () => condition c), [r])
                  | ("eterm : LPAREN FROM tables RPAREN", [l, from, tabs, r]) =>
                    brackets ([l], stmtNode [from, tabs], fn () => statement [fromClause (from, tabs)], [r])
                  | ("eterm : LPAREN SELECT1 query1 RPAREN", [l, s1, q, r]) =>
                    brackets ([l], stmtNode [s1, q], fn () => statement (([s1], tok s1) :: query1Clauses q), [r])
                  | ("eterm : LPAREN INSERT INTO texp LPAREN fields RPAREN VALUES LPAREN sqlexps RPAREN RPAREN",
                     [l, ins, into, t, l2, fs, r2, vals, l3, es, r3, r]) =>
                    brackets ([l], stmtNode [ins, into, t, l2, fs, r2, vals, l3, es, r3],
                              fn () => statement [([ins, into, t, l2, fs, r2],
                                                   clauseBracketed ([ins, into, t], l2, fn () => commaSeparated (l2, map elemItem (elemsSep fs), r2))),
                                                  ([vals, l3, es, r3],
                                                   clauseBracketed ([vals], l3, fn () => commaSeparated (l3, map elemItem (elemsSep es), r3)))],
                              [r])
                  | ("eterm : LPAREN INSERT INTO texp SET fsets RPAREN", [l, ins, into, t, set, fs, r]) =>
                    brackets ([l], stmtNode [ins, into, t, set, fs],
                              fn () => statement [([ins, into, t], words [ins, into, t]), ([set, fs], clauseList ([set], fsetItems fs))],
                              [r])
                  | ("eterm : LPAREN enterDml UPDATE texp SET fsets CWHERE sqlexp leaveDml RPAREN", [l, _, upd, t, set, fs, w, c, _, r]) =>
                    brackets ([l], stmtNode [upd, t, set, fs, w, c],
                              fn () => statement [([upd, t], words [upd, t]),
                                                  ([set, fs], clauseList ([set], fsetItems fs)),
                                                  ([w, c], clauseExpr ([w], c, fn () => condition c))],
                              [r])
                  | ("eterm : LPAREN enterDml DELETE FROM texp CWHERE sqlexp leaveDml RPAREN", [l, _, del, from, t, w, c, _, r]) =>
                    brackets ([l], stmtNode [del, from, t, w, c],
                              fn () => statement [([del, from, t], words [del, from, t]), ([w, c], clauseExpr ([w], c, fn () => condition c))],
                              [r])
                  | ("query : query1 obopt lopt ofopt", [q1, ob, lo, off]) => queryDoc (q1, ob, lo, off)
                  | ("decl : VIEW SYMBOL EQ LBRACE eexp RBRACE", [v, x, eq, l, e, r]) =>
                    group (tok v ^^ sp (tok x) ^^ sp (tok eq) ^^ nest 1 (sepFor (brokenBetween tbl (eq, l)) ^^ bracketed (l, e, r)))

                  (* SQL: the pieces *)
                  | ("sqlexp : sqlexp EQ sqlexp", _) => binop false node
                  | ("sqlexp : sqlexp NE sqlexp", _) => binop false node
                  | ("sqlexp : sqlexp LT sqlexp", _) => binop false node
                  | ("sqlexp : sqlexp LE sqlexp", _) => binop false node
                  | ("sqlexp : sqlexp GT sqlexp", _) => binop false node
                  | ("sqlexp : sqlexp GE sqlexp", _) => binop false node
                  | ("sqlexp : sqlexp PLUS sqlexp", _) => binop false node
                  | ("sqlexp : sqlexp MINUS sqlexp", _) => binop false node
                  | ("sqlexp : sqlexp STAR sqlexp", _) => binop false node
                  | ("sqlexp : sqlexp DIVIDE sqlexp", _) => binop false node
                  | ("sqlexp : sqlexp MOD sqlexp", _) => binop false node
                  | ("sqlexp : sqlexp CAND sqlexp", _) => binop false node
                  | ("sqlexp : sqlexp OR sqlexp", _) => binop false node
                  | ("sqlexp : sqlexp LIKE sqlexp", _) => binop false node
                  | ("sqlexp : sqlexp DISTANCE sqlexp", _) => binop false node
                  | ("sqlexp : NOT sqlexp", [n, e]) => tok n ^^ sp (f e)
                  | ("sqlexp : MINUS sqlexp", [m, e]) => tok m ^^ f e
                  | ("sqlexp : sqlexp IS NULL", [e, i, n]) => f e ^^ sp (tok i) ^^ sp (tok n)
                  | ("sqlexp : sqlexp IS NOT NULL", [e, i, nt, n]) => f e ^^ sp (tok i) ^^ sp (tok nt) ^^ sp (tok n)
                  | ("sqlexp : CIF sqlexp CTHEN sqlexp CELSE sqlexp", [i, c, t, a, e, b]) => ifExp (i, c, t, a, e, b)
                  | ("sqlexp : LBRACE LBRACK eexp RBRACK RBRACE", [l1, l2, e, r2, r1]) => brackets ([l1, l2], e, fn () => f e, [r2, r1])
                  | ("sqlexp : LBRACE eexp RBRACE", [l, e, r]) => bracketed (l, e, r)
                  | ("sqlexp : LPAREN query RPAREN", [l, q, r]) => bracketed (l, q, r)
                  | ("sqlexp : LPAREN sqlexp RPAREN", [l, e, r]) => brackets ([l], e, fn () => condition e, [r])
                  | ("sqlexp : COUNT LPAREN STAR RPAREN window", [c, l, s, r, w]) => tok c ^^ tok l ^^ sp (tok s) ^^ sp (tok r) ^^ windowDoc w   (* a paren directly before the star would open a comment *)
                  | ("sqlexp : COUNT LPAREN sqlexp RPAREN window", [c, l, e, r, w]) =>
                    tok c ^^ commaSeparated (l, [(Elem e, NONE)], r) ^^ windowDoc w
                  | ("sqlexp : sqlagg LPAREN sqlexp RPAREN window", [a, l, e, r, w]) =>
                    f a ^^ commaSeparated (l, [(Elem e, NONE)], r) ^^ windowDoc w
                  | ("sqlexp : RANK UNIT window", [rk, u, w]) => tok rk ^^ tok u ^^ windowDoc w
                  | ("sqlexp : COALESCE LPAREN sqlexp COMMA sqlexp RPAREN", [c, l, a, cm, b, r]) =>
                    tok c ^^ commaSeparated (l, [(Elem a, SOME cm), (Elem b, NONE)], r)
                  | ("sqlexp : fname LPAREN sqlexp RPAREN", [fn_, l, e, r]) => f fn_ ^^ commaSeparated (l, [(Elem e, NONE)], r)
                  | ("sqlexp : fname LPAREN sqlexp COMMA sqlexp RPAREN", [fn_, l, a, cm, b, r]) =>
                    f fn_ ^^ commaSeparated (l, [(Elem a, SOME cm), (Elem b, NONE)], r)
                  | ("sqlexp : tident DOT fident", [t, d, fi]) => f t ^^ tok d ^^ f fi
                  | ("window : OVER LPAREN pbopt obopt RPAREN", [ov, l, pb, ob, r]) =>
                    tok ov ^^ text " " ^^ brackets ([l], stmtNode [pb, ob], fn () => statement (optClause pb @ optClause ob), [r])
                  | ("seli : tident DOT fident", [t, d, fi]) => f t ^^ tok d ^^ f fi
                  | ("seli : sqlexp AS fident", [e, a, fi]) => f e ^^ sp (tok a) ^^ sp (f fi)
                  | ("seli : tident DOT LBRACE LBRACE cexp RBRACE RBRACE", [t, d, l1, l2, c, r2, r1]) =>
                    f t ^^ tok d ^^ brackets ([l1, l2], c, fn () => f c, [r2, r1])
                  | ("seli : tident DOT STAR", [t, d, s]) => f t ^^ tok d ^^ tok s
                  | ("groupi : tident DOT fident", [t, d, fi]) => f t ^^ tok d ^^ f fi
                  | ("groupi : tident DOT LBRACE LBRACE cexp RBRACE RBRACE", [t, d, l1, l2, c, r2, r1]) =>
                    f t ^^ tok d ^^ brackets ([l1, l2], c, fn () => f c, [r2, r1])
                  | ("tident : LBRACE LBRACE cexp RBRACE RBRACE", [l1, l2, c, r2, r1]) => brackets ([l1, l2], c, fn () => f c, [r2, r1])
                  | ("fident : LBRACE cexp RBRACE", [l, c, r]) => bracketed (l, c, r)
                  | ("tname : LBRACE cexp RBRACE", [l, c, r]) => bracketed (l, c, r)
                  | ("texp : LBRACE LBRACE eexp RBRACE RBRACE", [l1, l2, e, r2, r1]) => brackets ([l1, l2], e, fn () => f e, [r2, r1])
                  | ("fname : LBRACE eexp RBRACE", [l, e, r]) => bracketed (l, e, r)
                  | ("sqlint : LBRACE eexp RBRACE", [l, e, r]) => bracketed (l, e, r)
                  | ("diropt : LBRACE eexp RBRACE", [l, e, r]) => bracketed (l, e, r)
                  | ("obitem : sqlexp diropt", [e, d]) => f e ^^ (if isEmptyNode d then empty else sp (f d))
                  | ("table : SYMBOL AS tname", [s, a, t]) => tok s ^^ sp (tok a) ^^ sp (f t)
                  | ("table : LBRACE LBRACE eexp RBRACE RBRACE AS tname", [l1, l2, e, r2, r1, a, t]) =>
                    brackets ([l1, l2], e, fn () => f e, [r2, r1]) ^^ sp (tok a) ^^ sp (f t)
                  | ("fitem : LBRACE LBRACE eexp RBRACE RBRACE", [l1, l2, e, r2, r1]) => brackets ([l1, l2], e, fn () => f e, [r2, r1])
                  | ("fitem : LPAREN query RPAREN AS tname", [l, q, r, a, t]) => bracketed (l, q, r) ^^ sp (tok a) ^^ sp (f t)
                  | ("fitem : LPAREN LBRACE LBRACE eexp RBRACE RBRACE RPAREN AS tname", [l, l1, l2, e, r2, r1, r, a, t]) =>
                    tok l ^^ brackets ([l1, l2], e, fn () => f e, [r2, r1]) ^^ tok r ^^ sp (tok a) ^^ sp (f t)
                  | ("fitem : LPAREN fitem RPAREN", [l, fi, r]) => bracketed (l, fi, r)
                  | ("fitem : fitem JOIN fitem ON sqlexp", _) => joinChain node
                  | ("fitem : fitem INNER JOIN fitem ON sqlexp", _) => joinChain node
                  | ("fitem : fitem CROSS JOIN fitem", _) => joinChain node
                  | ("fitem : fitem LEFT JOIN fitem ON sqlexp", _) => joinChain node
                  | ("fitem : fitem LEFT OUTER JOIN fitem ON sqlexp", _) => joinChain node
                  | ("fitem : fitem RIGHT JOIN fitem ON sqlexp", _) => joinChain node
                  | ("fitem : fitem RIGHT OUTER JOIN fitem ON sqlexp", _) => joinChain node
                  | ("fitem : fitem FULL JOIN fitem ON sqlexp", _) => joinChain node
                  | ("fitem : fitem FULL OUTER JOIN fitem ON sqlexp", _) => joinChain node

                  (* SQL: table constraints *)
                  | ("pkopt : PRIMARY KEY pk", [p, k, pkn]) => clauseBracketed ([p, k], pkn, fn () => f pkn)
                  | ("pk : LBRACE LBRACE eexp RBRACE RBRACE", [l1, l2, e, r2, r1]) => brackets ([l1, l2], e, fn () => f e, [r2, r1])
                  | ("tnames : LPAREN tnames' RPAREN", [l, ts, r]) => commaSeparated (l, map elemItem (elemsSep ts), r)
                  | ("csts : CCONSTRAINT tname cst", [k, nm, cst]) => clauseExpr ([k, nm], cst, fn () => f cst)
                  | ("csts : LBRACE LBRACE eexp RBRACE RBRACE", [l1, l2, e, r2, r1]) => brackets ([l1, l2], e, fn () => f e, [r2, r1])
                  | ("cst : UNIQUE tnames", [u, ts]) => clauseBracketed ([u], ts, fn () => f ts)
                  | ("cst : CHECK sqlexp", [ch, e]) => clauseExpr ([ch], e, fn () => condition e)
                  | ("cst : FOREIGN KEY tnames REFERENCES texp LPAREN tnames' RPAREN pmodes", [fk, key, ts, refs, t, l, ts2, r, pms]) =>
                    statement ([([fk, key, ts], clauseBracketed ([fk, key], ts, fn () => f ts)),
                                ([refs, t, l, ts2, r],
                                 clauseBracketed ([refs], t, fn () => f t ^^ commaSeparated (l, map elemItem (elemsSep ts2), r)))]
                               @ map (fn pm => ([pm], f pm)) (elems pms))
                  | ("cst : LBRACE eexp RBRACE", [l, e, r]) => bracketed (l, e, r)
                  | ("pmode : ON pkind prule", [on, k, ru]) => words [on, k, ru]
                  | ("prule : NO ACTION", [a, b]) => words [a, b]
                  | ("prule : SET NULL", [a, b]) => words [a, b]

                  | _ => asWritten node

        (* `functor Make (M : sig ... end) : sig ... end`: the parameter and
         * the result signature one level deeper when they span lines *)
        and functorHead (k, x, l, m, c, sg, r, res) =
            let
                val param = group (tok l ^^ nest 1 (softline ^^ tok m ^^ sp (tok c) ^^ sp (f sg)) ^^ softline ^^ tok r)
                val resDoc = case res of
                                 SOME (c2, sg2) => line ^^ tok c2 ^^ sp (f sg2)
                               | NONE => empty
            in
                tok k ^^ sp (tok x) ^^ nest 1 (line ^^ param ^^ resDoc)
            end

        (* `vali AND vali`: each `and` at the level of the keyword *)
        and valis vs =
            let
                fun go [] = empty
                  | go [(v, _)] = f v
                  | go ((v, SOME andTok) :: rest) = f v ^^ hardline ^^ tok andTok ^^ text " " ^^ go rest
                  | go ((v, NONE) :: rest) = f v ^^ go rest
            in
                go (elemsSep vs)
            end

        (* rexp : DOTDOTDOT | rpath EQ eexp | rpath EQ eexp COMMA rexp *)
        and fields es =
            case es of
                Cst.Node {shape = "rexp : rpath EQ eexp COMMA rexp", kids = [p, eq, e, c, rest], ...} =>
                (Field (p, eq, e), SOME c) :: fields rest
              | Cst.Node {shape = "rexp : rpath EQ eexp", kids = [p, eq, e], ...} => [(Field (p, eq, e), NONE)]
              | other => [(Elem other, NONE)]

        (* rcon : | rpath EQ cexp | rpath EQ cexp COMMA rcon;  rcone likewise with COLON *)
        and tfields fs =
            case fs of
                Cst.Node {kids = [p, c, t, comma, Cst.Node {kids = [], ...}], ...} => [(Field (p, c, t), SOME comma)]
              | Cst.Node {kids = [p, c, t, comma, rest], ...} => (Field (p, c, t), SOME comma) :: tfields rest
              | Cst.Node {kids = [p, c, t], ...} => [(Field (p, c, t), NONE)]
              | Cst.Node {kids = [], ...} => []
              | other => [(Elem other, NONE)]

        and appChain e =
            case e of
                Cst.Node {shape = "eapps : eapps eterm", kids = [g, a], ...} =>
                let val (h, xs) = appChain g in (h, xs @ [a]) end
              | Cst.Node {shape = "eapps : eapps LBRACK cexp RBRACK", kids = [g, l, c, r], ...} =>
                let val (h, xs) = appChain g in (h, xs @ [Cst.node ("_", "capp", [l, c, r])]) end
              | Cst.Node {shape = "eapps : eapps BANG", kids = [g, b], ...} =>
                let val (h, xs) = appChain g in (h, xs @ [b]) end
              | _ => (e, [])

        and cappChain e =
            case e of
                Cst.Node {shape = "capps : capps cterm", kids = [g, a], ...} =>
                let val (h, xs) = cappChain g in (h, xs @ [a]) end
              | _ => (e, [])

        (* `datatype t = A | B of u`; broken, each constructor on its own
         * line one level deeper, with a leading bar *)
        and datatypes ts =
            let
                fun one t =
                    case t of
                        Cst.Node {shape = "dtype : SYMBOL dargs EQ barOpt dcons", kids = [x, args, eq, b0, cs], ...} =>
                        let
                            val cons = elemsSep cs
                            val bar0 = case b0 of Cst.Node {kids = [bar], ...} => SOME bar | _ => NONE
                            val broken = brokenList tbl (eq :: map #1 cons)
                                         orelse (case bar0 of SOME b => hasTrivia tbl (tokIndex b) | NONE => false)
                            val brk = sepFor broken
                            val seps = List.mapPartial #2 cons
                            fun items ([], _) = empty
                              | items ((c, _) :: rest, k) =
                                brk ^^ (if k = 0 then
                                            (case bar0 of
                                                 SOME b => ifBreak (tok b ^^ text " ") empty
                                               | NONE => ifBreak (text "| ") empty)
                                        else tok (List.nth (seps, k - 1)) ^^ text " ")
                                ^^ f c ^^ items (rest, k + 1)
                        in
                            group (tok x ^^ cat (map (fn a => sp (f a)) (elems args)) ^^ sp (tok eq)
                                   ^^ nest 1 (items (cons, 0)))
                        end
                      | other => asWritten other
                fun go [] = empty
                  | go [(t, _)] = one t
                  | go ((t, SOME andTok) :: rest) = one t ^^ hardline ^^ tok andTok ^^ text " " ^^ go rest
                  | go ((t, NONE) :: rest) = one t ^^ go rest
            in
                go (elemsSep ts)
            end

        (* ---- SQL ----------------------------------------------------------
         * A query or DML statement is on one line, or broken with every
         * clause on its own line at the statement's level.  A clause's
         * content follows its keywords on the line, or, when the author
         * broke after the keywords or broke a list of items, one level
         * deeper, one item per line with the comma after it.  JOINs at the
         * level of the first table, each ON one level deeper; AND/OR chains
         * with the operators one level deeper than the clause's keywords,
         * leading their operands.  Table constraints likewise. ----------- *)

        (* nodes on one line, a space between them; empty nodes skipped *)
        and words ns =
            let
                fun go [] = empty
                  | go [n] = f n
                  | go (n :: rest) = f n ^^ text " " ^^ go rest
            in
                go (List.filter (not o isEmptyNode) ns)
            end

        and stmtNode ns = Cst.node ("_", "stmt", ns)

        (* a statement of clauses, each given as its nodes (for the check
         * whether the author broke the line between clauses) and its
         * document, built by the caller in source order *)
        and statement (cs : (Cst.node list * doc) list) =
            let
                val broken = brokenList tbl (map (fn (ns, _) => stmtNode ns) cs)
                val sep = sepFor broken
                fun go [] = empty
                  | go [(_, d)] = d
                  | go ((_, d) :: rest) = d ^^ sep ^^ go rest
            in
                group (go cs)
            end

        (* `KEYWORDS content`: the content on the keywords' line, or one
         * level deeper when the author broke after them *)
        and clauseExpr (kws : Cst.node list, content : Cst.node, mk : unit -> doc) =
            let
                val head = words kws
                val d = mk ()
            in
                head ^^ nest 1 ((if brokenBetween tbl (List.last kws, content) then hardline else text " ") ^^ d)
            end

        (* the same for a bracketed content: below the keywords, one level
         * deeper, when it spans lines *)
        and clauseBracketed (kws : Cst.node list, content : Cst.node, mk : unit -> doc) =
            let
                val head = words kws
                val d = mk ()
            in
                head ^^ nest 1 ((if forced d orelse brokenBetween tbl (List.last kws, content) then hardline else text " ") ^^ d)
            end

        (* `KEYWORDS item, item`: on the keywords' line, or, when the author
         * broke after the keywords or between items, one item per line one
         * level deeper *)
        and clauseList (kws : Cst.node list, items) =
            let
                (* comments before the keywords go before the group, so that
                 * they do not break it *)
                val lead = case Cst.firstTok (List.hd kws) of
                               SOME {left, ...} => leadingDocs (Tbl.index tbl left)
                             | NONE => empty
                val head = words kws
                val ns = map (itemNode o #1) items
                val broken = brokenBetween tbl (List.last kws, List.hd ns) orelse brokenList tbl ns
                val id = newId ()
                val inner = listItems (id, items, broken)
            in
                lead ^^ groupNamed id (head ^^ nest 1 (sepFor broken ^^ inner))
            end

        (* a condition: an AND/OR chain has its operators at the current
         * level, leading their operands, broken where the author broke it *)
        and condition e =
            case e of
                Cst.Node {shape = "sqlexp : sqlexp CAND sqlexp", ...} => condChain (e, "CAND")
              | Cst.Node {shape = "sqlexp : sqlexp OR sqlexp", ...} => condChain (e, "OR")
              | _ => f e

        and condChain (e, opKind) =
            let
                val (operands, ops) = flattenChain (e, opKind)
                val brk = sepFor (brokenList tbl operands)
                val first = f (List.hd operands)
            in
                group (first ^^ cat (ListPair.map (fn (opr, x) => brk ^^ leading (opr, x)) (ops, List.tl operands)))
            end

        and queryDoc (q1, ob, lo, off) = statement (query1Clauses q1 @ List.concat (map optClause [ob, lo, off]))

        and query1Clauses n =
            case n of
                Cst.Node {shape = "query1 : SELECT dopt select FROM tables wopt gopt hopt", kids = [sel, dopt, items, from, tabs, w, g, h], ...} =>
                selectClause (sel, dopt, items) :: fromClause (from, tabs) :: List.concat (map optClause [w, g, h])
              | Cst.Node {shape = "query1 : LBRACE LBRACE LBRACE eexp RBRACE RBRACE RBRACE", kids = [l1, l2, l3, e, r3, r2, r1], ...} =>
                [([n], brackets ([l1, l2, l3], e, fn () => f e, [r3, r2, r1]))]
              | Cst.Node {kids = [a, u, b], ...} => query1Clauses a @ [([u], tok u)] @ query1Clauses b
              | Cst.Node {kids = [a, u, al, b], ...} => query1Clauses a @ [([u, al], words [u, al])] @ query1Clauses b
              | _ => [([n], asWritten n)]

        and selectClause (sel, dopt, items) =
            let
                val kws = if isEmptyNode dopt then [sel] else [sel, dopt]
            in
                ([sel, dopt, items],
                 case items of
                     Cst.Node {shape = "select : selis", kids = [selis], ...} => clauseList (kws, map elemItem (elemsSep selis))
                   | _ => clauseExpr (kws, items, fn () => f items))
            end

        (* `FROM t JOIN u ON ...`: the JOINs of a single table expression
         * are at the level of FROM (joinChain); several tables make a list *)
        and fromClause (from, tabs) =
            ([from, tabs],
             case elemsSep tabs of
                 [(t, NONE)] =>
                 if brokenBetween tbl (from, t) then clauseExpr ([from], t, fn () => f t)
                 else tok from ^^ text " " ^^ f t
               | items => clauseList ([from], map elemItem items))

        (* the optional clauses: nothing for an empty one *)
        and optClause n =
            if isEmptyNode n then []
            else
                [([n],
                  case n of
                      Cst.Node {shape = "wopt : CWHERE sqlexp", kids = [w, e], ...} => clauseExpr ([w], e, fn () => condition e)
                    | Cst.Node {shape = "hopt : HAVING sqlexp", kids = [h, e], ...} => clauseExpr ([h], e, fn () => condition e)
                    | Cst.Node {shape = "gopt : GROUP BY groupis", kids = [g, b, gs], ...} => clauseList ([g, b], map elemItem (elemsSep gs))
                    | Cst.Node {shape = "obopt : ORDER BY obexps", kids = [ob, by, es], ...} => clauseList ([ob, by], map elemItem (elemsSep es))
                    | Cst.Node {shape = "obopt : ORDER BY LBRACE LBRACE LBRACE eexp RBRACE RBRACE RBRACE", kids = [ob, by, l1, l2, l3, e, r3, r2, r1], ...} =>
                      clauseBracketed ([ob, by], l1, fn () => brackets ([l1, l2, l3], e, fn () => f e, [r3, r2, r1]))
                    | Cst.Node {shape = "lopt : LIMIT ALL", kids = [l, a], ...} => words [l, a]
                    | Cst.Node {shape = "lopt : LIMIT sqlint", kids = [l, i], ...} => clauseExpr ([l], i, fn () => f i)
                    | Cst.Node {shape = "ofopt : OFFSET sqlint", kids = [off, i], ...} => clauseExpr ([off], i, fn () => f i)
                    | Cst.Node {shape = "pbopt : PARTITION BY sqlexp", kids = [p, b, e], ...} => clauseExpr ([p, b], e, fn () => f e)
                    | _ => asWritten n)]

        (* `a JOIN b ON c LEFT JOIN d ON e`: on one line, or each JOIN on its
         * own line at the level of the first table, its ON one level deeper *)
        and joinChain node =
            let
                fun splitJoin (acc, k :: rest) = if isTok "JOIN" k then (rev (k :: acc), rest) else splitJoin (k :: acc, rest)
                  | splitJoin (acc, []) = (rev acc, [])
                fun parts n =
                    case n of
                        Cst.Node {shape, kids = base :: rest, ...} =>
                        if String.isPrefix "fitem : fitem " shape then
                            let val (b, joins) = parts base in (b, joins @ [splitJoin ([], rest)]) end
                        else (n, [])
                      | _ => (n, [])
                val (base, joins) = parts node
                val broken = brokenList tbl (base :: map (fn (kws, _) => List.hd kws) joins)
                val sep = sepFor broken
                val first = f base
                (* the table on the JOIN's line, or, spanning lines (a
                 * subquery), below it one level deeper *)
                fun table t =
                    let
                        val d = f t
                    in
                        if forced d then nest 1 (hardline ^^ d) else text " " ^^ d
                    end
                fun join (kws, after) =
                    case after of
                        [t] => sep ^^ words kws ^^ table t
                      | [t, on, c] => sep ^^ words kws ^^ table t ^^ nest 1 (sep ^^ clauseExpr ([on], c, fn () => condition c))
                      | _ => sep ^^ words (kws @ after)
            in
                group (first ^^ cat (map join joins))
            end

        and windowDoc w = if isEmptyNode w then empty else text " " ^^ f w

        (* fsets : fident EQ sqlexp | fident EQ sqlexp COMMA fsets *)
        and fsetItems n =
            case n of
                Cst.Node {kids = [p, eq, e, c, rest], ...} => (Field (p, eq, e), SOME c) :: fsetItems rest
              | Cst.Node {kids = [p, eq, e], ...} => [(Field (p, eq, e), NONE)]
              | other => [(Elem other, NONE)]

        (* cstopt : csts;  csts : CCONSTRAINT tname cst | csts COMMA csts | {{e}} *)
        and constraintItems n =
            case n of
                Cst.Node {shape = "cstopt : csts", kids = [cs], ...} => constraintItems cs
              | Cst.Node {shape = "csts : csts COMMA csts", kids = [a, cm, b], ...} =>
                let
                    val l = constraintItems a
                    val (lastC, _) = List.last l
                in
                    List.take (l, length l - 1) @ [(lastC, SOME cm)] @ constraintItems b
                end
              | other => [(other, NONE)]

        (* table x : type PRIMARY KEY ..., CONSTRAINT ...: the type and each
         * constraint on its own line one level deeper when broken *)
        and tableDecl (t, x, c, ty, pk, comma, cst) =
            let
                val parts = List.filter (not o isEmptyNode) [ty, pk, cst]
                val broken = brokenList tbl (c :: parts)
                val brk = sepFor broken
                val tyDoc = f ty
                val pkDoc = if isEmptyNode pk then empty else brk ^^ f pk
                val commaDoc = case comma of Cst.Node {kids = [cm], ...} => tok cm | _ => empty
                val cstDoc = cat (map (fn (n, sep) => brk ^^ f n ^^ (case sep of SOME s => tok s | NONE => empty))
                                      (if isEmptyNode cst then [] else constraintItems cst))
            in
                group (tok t ^^ sp (tok x) ^^ sp (tok c) ^^ nest 1 (brk ^^ tyDoc ^^ pkDoc ^^ commaDoc ^^ cstDoc))
            end

        (* ---- as written: the author's lines, each at its depth relative
         * to the first, by tabs alone; inside a line, one space where there
         * was whitespace; embedded expressions and types formatted by their
         * own rules ------------------------------------------------------- *)
        and asWritten node =
            let
                fun units n =
                    case n of
                        Cst.Tok _ => [n]
                      | Cst.Node {nt = "eexp", ...} => [n]
                      | Cst.Node {nt = "cexp", ...} => [n]
                      | Cst.Node {kids, ...} => List.concat (map units kids)
                val us = case node of
                             Cst.Node {kids, ...} => List.concat (map units kids)
                           | _ => [node]
                val depth0 = depthOf tbl node
                fun unitDoc u = case u of Cst.Tok t => tokDoc t | _ => f u
                fun go (_, []) = empty
                  | go (prev, u :: rest) =
                    let
                        val d = unitDoc u
                        val piece =
                            case prev of
                                NONE => d
                              | SOME p =>
                                let
                                    val gap = gapText tbl (p, u)
                                in
                                    if hasNewline gap then
                                        (* a new line: at its depth relative to the node's first line *)
                                        let
                                            val i = tokIndex (Cst.Tok (valOf (Cst.firstTok u)))
                                            val depth = Vector.sub (#depths tbl, i)
                                        in
                                            nest (Int.max (0, depth - depth0))
                                                 ((if #blankBefore (Vector.sub (#gaps tbl, i)) then blankline else hardline) ^^ d)
                                        end
                                    else if gap = "" then d
                                    else text " " ^^ d
                                end
                    in
                        piece ^^ go (SOME u, rest)
                    end
            in
                go (NONE, us)
            end

        (* ---- XML -------------------------------------------------------- *)
        (* An XML literal is a flat sequence of items in source order: open,
         * close and self-closing tags, text, embedded expressions and line
         * breaks (the lexer makes each newline in XML text its own token).
         * The output keeps the author's lines; each line is indented by the
         * tag nesting at its start, a line starting with a closing tag at
         * the level of the element it closes.  Whitespace-only text at the
         * ends of a line is indentation and is dropped; other whitespace
         * runs become one space.  Nothing else changes: where there was
         * no whitespace between two nodes there is none, where there was
         * some there is some. *)
        and xmlLiteral (b, x, e) =
            let
                datatype item = Open of doc * bool (* self-closing *)
                              | Close of doc
                              | Text of int (* token index *) * string
                              | Hole of doc
                              | Newline of int
                (* elements whose content is whitespace-sensitive: kept as written *)
                val preformatted = ["pre", "textarea"]
                (* the name in `<name`, through `<name{...}` heads *)
                fun headName th =
                    case th of
                        Cst.Node {shape = "tagHead : BEGIN_TAG", kids = [Cst.Tok t], ...} =>
                        (case String.tokens (fn c => c = #"<") (tokText tbl t) of
                             [name] => SOME name
                           | _ => NONE)
                      | Cst.Node {shape = "tagHead : tagHead LBRACE cexp RBRACE", kids = th' :: _, ...} => headName th'
                      | _ => NONE
                fun tagName tg =
                    case tg of
                        Cst.Node {kids = [th, _], ...} => headName th
                      | _ => NONE
                fun verbatimElement n =
                    case (Cst.firstTok n, Cst.lastTok n) of
                        (SOME (a as {left, ...}), SOME (b as {right, ...})) =>
                        leadingDocs (Tbl.index tbl left)
                        ^^ raw (String.substring (#src tbl, left, right - left))
                        ^^ trailingDocs tbl (Tbl.index tbl (#left b) + 1)
                      | _ => empty
                fun items n =
                    case n of
                        Cst.Node {shape = "xml : xmlOne xml", kids = [a, rest], ...} => items a @ items rest
                      | Cst.Node {shape = "xml : xmlOne", kids = [a], ...} => items a
                      | Cst.Node {shape = "xmlOpt : xml", kids = [a], ...} => items a
                      | Cst.Node {shape = "xmlOpt : ", ...} => []
                      | Cst.Node {shape = "xmlOne : NOTAGS", kids = [Cst.Tok (t as {left, ...})], ...} =>
                        let val s = tokText tbl t
                        in if s = "\n" then [Newline (Tbl.index tbl left)] else [Text (Tbl.index tbl left, s)] end
                      | Cst.Node {shape = "xmlOne : tag DIVIDE GT", kids = [tg, d, g], ...} =>
                        [Open (tagDoc (tg, [d, g]), true)]
                      | Cst.Node {shape = "xmlOne : tag GT xmlOpt END_TAG", kids = [tg, g, content, et], ...} =>
                        if (case tagName tg of SOME nm => List.exists (fn p => p = nm) preformatted | NONE => false)
                        then [Hole (verbatimElement n)]
                        else Open (tagDoc (tg, [g]), false) :: items content @ [Close (tok et)]
                      | Cst.Node {shape = "xmlOne : LBRACE eexp RBRACE", kids = [l, ex, r], ...} =>
                        [Hole (bracketed (l, ex, r))]
                      | Cst.Node {shape = "xmlOne : LBRACE LBRACK eexp RBRACK RBRACE", kids = [l1, l2, ex, r2, r1], ...} =>
                        [Hole (brackets ([l1, l2], ex, fn () => f ex, [r2, r1]))]
                      | other => [Hole (asWritten other)]
                val all = Open (tok b, false) :: items x @ [Close (tok e)]

                fun isWs s = CharVector.all Char.isSpace s
                fun collapse s =
                    let
                        val ws = String.tokens Char.isSpace s
                        val lead = size s > 0 andalso Char.isSpace (String.sub (s, 0))
                        val trail = size s > 0 andalso Char.isSpace (String.sub (s, size s - 1))
                    in
                        (if lead then " " else "") ^ String.concatWith " " ws
                        ^ (if trail andalso not (null ws) then " " else "")
                    end
                fun dropLead s = if String.isPrefix " " s then String.extract (s, 1, NONE) else s
                fun dropTrail s = if String.isSuffix " " s then String.substring (s, 0, size s - 1) else s
                (* the comments around a token that is not printed itself *)
                fun leadTrivia i = leadingDocs i ^^ cat (map commentDoc (#trailing (Vector.sub (#gaps tbl, i + 1))))
                (* the dropped text was whitespace, so a comment after it
                 * had whitespace before it *)
                fun trailTrivia i =
                    leadingDocs i
                    ^^ cat (ListPair.map (fn (k, c) => (if k = 0 orelse not (#joined c) then text " " else empty) ^^ commentDoc c)
                                         (List.tabulate (length (#trailing (Vector.sub (#gaps tbl, i + 1))), fn k => k),
                                          #trailing (Vector.sub (#gaps tbl, i + 1))))
                fun textDoc (i, s) = leadingDocs i ^^ text s ^^ trailingDocs tbl (i + 1)

                (* lines: (items, index of the newline token ending it) *)
                fun splitLines its =
                    let
                        fun go (its, cur, acc) =
                            case its of
                                [] => rev ((rev cur, NONE) :: acc)
                              | Newline i :: rest => go (rest, [], (rev cur, SOME i) :: acc)
                              | it :: rest => go (rest, it :: cur, acc)
                    in
                        go (its, [], [])
                    end

                (* whitespace-only text at the ends of a line: dropped, its
                 * comments kept; also says whether any were there *)
                fun hasComments i =
                    not (null (#leading (Vector.sub (#gaps tbl, i))))
                    orelse not (null (#trailing (Vector.sub (#gaps tbl, i + 1))))
                fun stripEnds (its, atStart, atEnd) =
                    let
                        fun strip trivia [] = ([], [], false)
                          | strip trivia (Text (i, s) :: rest) =
                            if isWs s then
                                let val (tr, r, c) = strip trivia rest
                                in (trivia i :: tr, r, c orelse hasComments i) end
                            else ([], Text (i, s) :: rest, false)
                          | strip _ its = ([], its, false)
                        val (leadT, its, c1) = if atStart then strip leadTrivia its else ([], its, false)
                        val (trailT, itsRev, c2) = if atEnd then strip trailTrivia (rev its) else ([], rev its, false)
                    in
                        (cat leadT, rev itsRev, cat (rev trailT), c1 orelse c2)
                    end

                fun lineDoc (its, stripLead, stripTrail) =
                    let
                        val n = length its
                        fun go (_, []) = empty
                          | go (k, it :: rest) =
                            (case it of
                                 Text (i, s) =>
                                 let
                                     val s = collapse s
                                     val s = if k = 0 andalso stripLead then dropLead s else s
                                     val s = if k = n - 1 andalso stripTrail then dropTrail s else s
                                 in
                                     textDoc (i, s)
                                 end
                               | Open (d, _) => d
                               | Close d => d
                               | Hole d => d
                               | Newline _ => empty)
                            ^^ go (k + 1, rest)
                    in
                        go (0, its)
                    end

                (* The elements still open, innermost first, each with the
                 * depth of the line that opened it: a line is one level
                 * deeper than the line that opened the innermost element
                 * around it, however many elements that line opened. *)
                fun opened (its, lineDepth, stack) =
                    case its of
                        [] => stack
                      | Open (_, false) :: r => opened (r, lineDepth, lineDepth :: stack)
                      | Close _ :: r => opened (r, lineDepth, case stack of _ :: s => s | [] => [])
                      | _ :: r => opened (r, lineDepth, stack)

                (* comments after the newline token that ended the previous
                 * line are on their own line(s) before this one *)
                fun afterNewline nl =
                    case nl of
                        SOME i => cat (map (fn c => commentDoc c ^^ hardline)
                                           (#trailing (Vector.sub (#gaps tbl, i + 1))))
                      | NONE => empty

                (* the lines after the first, at their depth: inside the
                 * innermost open element, or, for a line starting with a
                 * closing tag, at the depth of the line that opened it *)
                fun render (ls, prevNl, stack, acc, prevBlank) =
                    case ls of
                        [] => acc
                      | (its, nl) :: rest =>
                        let
                            val last = case nl of NONE => true | SOME _ => false
                            val (leadT, core, trailT, comments) = stripEnds (its, true, not last)
                            val startsWithClose = case core of Close _ :: _ => true | _ => false
                            val lineDepth = case stack of
                                                d :: _ => if startsWithClose then d else d + 1
                                              | [] => 0
                            val content = afterNewline prevNl ^^ leadT ^^ lineDoc (core, true, not last) ^^ trailT
                            val blank = null core andalso not comments
                            val acc' =
                                if blank then
                                    (if prevBlank then acc ^^ content
                                     else acc ^^ nest lineDepth (blankline ^^ content))
                                else acc ^^ nest lineDepth (hardline ^^ content)
                        in
                            render (rest, nl, opened (core, lineDepth, stack), acc', blank)
                        end
            in
                case splitLines all of
                    [(its, NONE)] => lineDoc (its, false, false)
                  | (its0, nl0) :: rest =>
                    let
                        val (leadT, core, trailT, _) = stripEnds (its0, false, true)
                    in
                        leadT ^^ lineDoc (core, false, true) ^^ trailT
                        ^^ render (rest, nl0, opened (core, 0, []), empty, false)
                    end
                  | [] => empty
            end

        (* `<name a=1 b={e}>`: attributes on the line, or one per line one
         * level deeper with the `>` back at the tag's level.  A self-closing
         * tag ends `<name a=1 />`, or with `/>` on its own line. *)
        and tagDoc (tg, closing) =
            let
                val space = if length closing = 2 then text " " else empty
            in
                case tg of
                    Cst.Node {shape = "tag : tagHead attrs", kids = [th, attrs], ...} =>
                    let
                        val as_ = elems attrs
                        val broken = brokenList tbl (th :: as_ @ [List.hd closing])
                    in
                        group (f th ^^ nest 1 (cat (map (fn a => sepFor broken ^^ f a) as_))
                               ^^ (if null as_ then space else ifBreak hardline space)
                               ^^ cat (map tok closing))
                    end
                  | other => asWritten other ^^ space ^^ cat (map tok closing)
            end

        val doc = f cst
        (* comments after the last token, each on its own line *)
        val lastGap = Vector.sub (#gaps tbl, ntoks)
        val trailing = cat (map (fn c => (if #blankBefore c then blankline else hardline) ^^ commentDoc c)
                                (#leading lastGap))
    in
        let
            val s = Doc.render {width = !width, tabwidth = !tabwidth} (doc ^^ trailing)
            (* no blank lines at the start, exactly one newline at the end *)
            val s = Substring.string (Substring.dropr Char.isSpace (Substring.dropl (fn c => c = #"\n") (Substring.full s)))
        in
            s ^ "\n"
        end
    end

end
