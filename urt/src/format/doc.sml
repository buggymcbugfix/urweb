(* A Wadler-style document type and layout algorithm ("A prettier printer",
 * 2003).  Indentation is in tabs: `nest 1` is one tab deeper.
 *
 * Additions for the formatter:
 *   ifBreak  - one document when the enclosing group is broken, another
 *              when it is flat (e.g. the leading "| " of a case branch);
 *   groupNamed, ifBreakOf - a group with an identity, so that a choice
 *              deeper inside can depend on whether *that* group is broken
 *              rather than the innermost one (the padding that aligns the
 *              `=` of record fields when the record is broken);
 *   blankline - an empty line, for blank lines the author had;
 *   raw      - text emitted exactly as given (string literals);
 *   block    - multi-line text re-indented so that its continuation lines
 *              keep their depth relative to its first line (comments);
 * and two policies: a line break directly after a line break is one line
 * break (so nested constructs that each want to start on a fresh line do
 * not produce blank lines), and blank lines carry no indentation.
 *
 * A width of 0 means no width limit: groups then break only where the
 * document forces them to (hard lines). *)

structure Doc :> sig
    type doc
    val empty : doc
    val text : string -> doc
    val line : doc      (* newline, or a space when the group is flat *)
    val softline : doc  (* newline, or nothing when the group is flat *)
    val hardline : doc
    val blankline : doc
    val cat : doc list -> doc
    val ^^ : doc * doc -> doc
    val nest : int -> doc -> doc
    val group : doc -> doc
    val ifBreak : doc -> doc -> doc
    type id
    val newId : unit -> id
    val groupNamed : id -> doc -> doc
    val ifBreakOf : id -> doc -> doc -> doc  (* by the mode of the named group; flat if it is not enclosing *)
    val raw : string -> doc
    val block : int (* tab depth of the first line in the source *) -> string -> doc
    val forced : doc -> bool
    val render : {width : int, tabwidth : int} -> doc -> string
end = struct

datatype doc =
         Empty
       | Text of string
       | Line
       | SoftLine
       | HardLine
       | BlankLine
       | Cat of doc * doc
       | Nest of int * doc
       | Group of doc
       | IfBreak of doc * doc
       | Named of int * doc
       | IfBreakOf of int * doc * doc
       | Raw of string
       | Block of int * string

type id = int
val nextId = ref 0
fun newId () = !nextId before nextId := !nextId + 1

val empty = Empty
val text = Text
val line = Line
val softline = SoftLine
val hardline = HardLine
val blankline = BlankLine
infixr 5 ^^
fun a ^^ b = Cat (a, b)
fun cat ds = foldr Cat Empty ds
fun nest n d = Nest (n, d)
fun group d = Group d
fun ifBreak a b = IfBreak (a, b)
fun groupNamed id d = Named (id, d)
fun ifBreakOf id a b = IfBreakOf (id, a, b)
val raw = Raw
fun block c s = Block (c, s)

fun hasNewline s = CharVector.exists (fn c => c = #"\n") s

(* does laying out d flat necessarily fail? *)
fun forced d =
    case d of
        HardLine => true
      | BlankLine => true
      | Raw s => hasNewline s
      | Block (_, s) => hasNewline s
      | Cat (a, b) => forced a orelse forced b
      | Nest (_, d) => forced d
      | Group d => forced d
      | IfBreak (_, flat) => forced flat
      | Named (_, d) => forced d
      | IfBreakOf (_, _, flat) => forced flat
      | _ => false

datatype mode = Flat | Break

(* leading whitespace of a line as (tabs, spaces, rest): spaces count as
 * tabs in units of tabwidth, the remainder is kept as alignment *)
fun indentation tabwidth l =
    let
        fun go (i, tabs, spaces) =
            if i < size l then
                case String.sub (l, i) of
                    #"\t" => go (i + 1, tabs + 1, spaces)
                  | #" " => go (i + 1, tabs, spaces + 1)
                  | _ => (i, tabs, spaces)
            else (i, tabs, spaces)
        val (i, tabs, spaces) = go (0, 0, 0)
    in
        (tabs + spaces div tabwidth, spaces mod tabwidth, String.extract (l, i, NONE))
    end

fun render {width, tabwidth} d =
    let
        val out = ref ([] : string list)
        val col = ref 0
        (* the mode of each named group, once the layout reaches it; Flat
         * before that, which is how `fits` measures a group it has not
         * had to break *)
        val modes = Array.array (!nextId, Flat)
        (* indentation owed after a newline, paid when text follows *)
        val pending = ref (NONE : int option)
        (* the line before the pending one is empty: a second blank line is one *)
        val lastBlank = ref false
        (* a separating space is owed; dropped if a line break comes first *)
        val space = ref false
        fun tabs n = CharVector.tabulate (n, fn _ => #"\t")
        fun emit s =
            (case !pending of
                 SOME i => (out := tabs i :: !out; pending := NONE; lastBlank := false)
               | NONE => ();
             if !space then (out := " " :: !out; space := false) else ();
             out := s :: !out)
        (* a line break right after a line break replaces it *)
        fun newline i =
            (space := false;
             case !pending of
                 SOME _ => ()
               | NONE => out := "\n" :: !out;
             pending := SOME i;
             col := i * tabwidth)
        fun blank i =
            (space := false;
             case !pending of
                 SOME _ => ()
               | NONE => out := "\n" :: !out;
             if !lastBlank then () else out := "\n" :: !out;
             lastBlank := true;
             pending := SOME i;
             col := i * tabwidth)
        (* an empty line inside verbatim text: never merged with another *)
        fun emptyLine () =
            (space := false;
             case !pending of
                 SOME _ => ()
               | NONE => out := "\n" :: !out;
             out := "\n" :: !out;
             lastBlank := true;
             pending := SOME 0;
             col := 0)

        fun firstLineWidth s =
            case CharVector.findi (fn (_, c) => c = #"\n") s of
                SOME (i, _) => i
              | NONE => size s

        (* fits: can the items be laid out in the remaining width?  In Flat
         * mode everything is measured flat.  In Break mode the measurement
         * stops at the first line break; groups inside are measured flat
         * unless they must break. *)
        fun fits (w, []) = w >= 0
          | fits (w, (i, m, d) :: rest) =
            w >= 0 andalso
            (case d of
                 Empty => fits (w, rest)
               | Text s => fits (w - size s, rest)
               | Line => (case m of Flat => fits (w - 1, rest) | Break => true)
               | SoftLine => (case m of Flat => fits (w, rest) | Break => true)
               | HardLine => true
               | BlankLine => true
               | Cat (a, b) => fits (w, (i, m, a) :: (i, m, b) :: rest)
               | Nest (j, d) => fits (w, (i + j, m, d) :: rest)
               | Group d => fits (w, (i, if forced d then Break else Flat, d) :: rest)
               | IfBreak (b, f) => fits (w, (i, m, case m of Flat => f | Break => b) :: rest)
               | Named (_, d) => fits (w, (i, if forced d then Break else Flat, d) :: rest)
               | IfBreakOf (id, b, f) => fits (w, (i, m, case Array.sub (modes, id) of Flat => f | Break => b) :: rest)
               | Raw s => if hasNewline s then w - firstLineWidth s >= 0 else fits (w - size s, rest)
               | Block (_, s) => if hasNewline s then w - firstLineWidth s >= 0 else fits (w - size s, rest))

        fun emitRaw s =
            (emit s;
             case rev (String.fields (fn c => c = #"\n") s) of
                 [only] => col := !col + size only
               | last :: _ => col := size last
               | [] => ())

        (* flat if the group can be, and fits in the remaining width *)
        fun groupMode (i, d, rest) =
            if not (forced d) andalso (width = 0 orelse fits (width - !col, (i, Flat, d) :: rest)) then Flat
            else Break

        fun go [] = ()
          | go ((i, m, d) :: rest) =
            case d of
                Empty => go rest
              | Text "" => go rest
              | Text " " => (space := true; col := !col + 1; go rest)
              | Text s => (emit s; col := !col + size s; go rest)
              | Line => (case m of
                             Flat => (space := true; col := !col + 1)
                           | Break => newline i;
                         go rest)
              | SoftLine => (case m of
                                 Flat => ()
                               | Break => newline i;
                             go rest)
              | HardLine => (newline i; go rest)
              | BlankLine => (blank i; go rest)
              | Cat (a, b) => go ((i, m, a) :: (i, m, b) :: rest)
              | Nest (j, d) => go ((i + j, m, d) :: rest)
              | Group d => go ((i, groupMode (i, d, rest), d) :: rest)
              | IfBreak (b, f) => go ((i, m, case m of Flat => f | Break => b) :: rest)
              | Named (id, d) =>
                let val m' = groupMode (i, d, rest)
                in Array.update (modes, id, m'); go ((i, m', d) :: rest) end
              | IfBreakOf (id, b, f) => go ((i, m, case Array.sub (modes, id) of Flat => f | Break => b) :: rest)
              | Raw s => (emitRaw s; go rest)
              | Block (depth0, s) =>
                (* continuation lines: the first depth0 tabs' worth of their
                 * indentation stands for the block's original nesting and is
                 * replaced by the current one; what is deeper is kept, as
                 * tabs, with the spaces that do not make a tab after them *)
                (case String.fields (fn c => c = #"\n") s of
                     [] => go rest
                   | first :: more =>
                     (emit first; col := !col + size first;
                      app (fn l =>
                              let
                                  val (tabs, spaces, body) = indentation tabwidth l
                              in
                                  if body = "" then emptyLine ()
                                  else
                                      let
                                          val lead = CharVector.tabulate (spaces, fn _ => #" ")
                                      in
                                          newline (i + Int.max (0, tabs - depth0));
                                          emit (lead ^ body);
                                          col := !col + spaces + size body
                                      end
                              end) more;
                      go rest))
    in
        go [(0, Break, d)];
        String.concat (rev (!out))
    end

end
