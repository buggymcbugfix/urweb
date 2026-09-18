(* urt format command line (urt hands the arguments after `format` to
 * this program, urt-format).
 *
 *   urt format [options] FILE...        format each file to stdout
 *   urt format -i [options] FILE...     rewrite each file in place (only if it changes)
 *   urt format -check [options] FILE...
 *                                       exit 1 if any file is not already formatted
 *   urt format [options] < FILE         stdin to stdout (-urs: the input is a signature)
 *
 * options: -width N     break lines longer than N columns (default 0: no limit)
 *          -tabwidth N  columns per tab (default 4)
 *          -verbatim | -dump | -shapes | -comments | -canonical | -unchecked   (development)
 *
 * Every run parses the input and its formatted output with the compiler's
 * own grammar and requires the two ASTs to be equal (check.sml).  If they
 * are not, nothing is written and the exit status is 2.
 *
 * Exit status: 0 ok; 1 a file needs formatting (-check) or does not parse;
 * 2 the formatter would change the program (a formatter bug: please report). *)

structure Main = struct

fun err msg = TextIO.output (TextIO.stdErr, msg ^ "\n")

datatype mode = Stdout | InPlace | Check | Verbatim | Dump | Shapes | Comments | Canonical | Unchecked

fun readAll strm = TextIO.inputAll strm

fun writeFile (name, s) =
    let
        val f = TextIO.openOut name
    in
        TextIO.output (f, s);
        TextIO.closeOut f
    end

(* format one parsed file, with the semantic check; NONE on failure (reported) *)
fun formatChecked (name, cst, src) =
    let
        val out = Format.format src cst
    in
        case Parse.parseText (name, out) of
            NONE => (err (name ^ ": internal error: the formatted output does not parse; file left alone"); NONE)
          | SOME (cst', out') =>
            case Check.same {name = name, pre = (cst, src), post = (cst', out')} of
                NONE => SOME out
              | SOME what =>
                (err (name ^ ": internal error: formatting would change the program (" ^ what ^ "); file left alone");
                 NONE)
    end

(* returns the exit status for one input *)
fun run mode (name, parsed) =
    case parsed of
        NONE => (err (name ^ ": parse failed"); 1)
      | SOME (cst, src) =>
        case mode of
            Verbatim => (print (Verbatim.reprint src cst); 0)
          | Dump => (print (Cst.dump src cst); 0)
          | Shapes => (app (fn (s, n) => print (Int.toString n ^ "\t" ^ s ^ "\n")) (Cst.countShapes cst); 0)
          | Comments => (app (fn c => print (String.toString c ^ "\n")) (Verbatim.comments src cst); 0)
          | Canonical => (print (Check.canonical (cst, src)); 0)
          | Unchecked => (print (Format.format src cst); 0)
          | Stdout => (case formatChecked (name, cst, src) of
                           SOME out => (print out; 0)
                         | NONE => 2)
          | InPlace => (case formatChecked (name, cst, src) of
                            SOME out => (if out <> src then writeFile (name, out) else (); 0)
                          | NONE => 2)
          | Check => (case formatChecked (name, cst, src) of
                          SOME out => if out = src then 0 else (err (name ^ ": not formatted"); 1)
                        | NONE => 2)

val usageText =
    "usage: urt format [-i | -check] [-width N] [-tabwidth N] FILE...\n\
    \       urt format [-urs] [options] < FILE\n\
    \\n\
    \Format Ur/Web sources in the style of urt/src/format/STYLE.md.\n\
    \\n\
    \  -i           rewrite the files in place (only those that change)\n\
    \  -check       exit 1 if any file is not already formatted (for CI)\n\
    \  -width N     break lines longer than N columns (default 0: no limit)\n\
    \  -tabwidth N  columns per tab (default 4)\n\
    \  -urs         the input on stdin is a signature\n\
    \\n\
    \Every run parses the input and its output with the compiler's grammar\n\
    \and requires the two programs to be the same; otherwise nothing is\n\
    \written and the exit status is 2.\n"

fun usage () = (err usageText; OS.Process.exit OS.Process.failure)

fun help () = (print usageText; OS.Process.exit OS.Process.success)

fun main args =
    let
        val mode = ref Stdout
        val urs = ref false
        fun opts args =
            case args of
                "-i" :: rest => (mode := InPlace; opts rest)
              | "-check" :: rest => (mode := Check; opts rest)
              | "-verbatim" :: rest => (mode := Verbatim; opts rest)
              | "-dump" :: rest => (mode := Dump; opts rest)
              | "-shapes" :: rest => (mode := Shapes; opts rest)
              | "-comments" :: rest => (mode := Comments; opts rest)
              | "-canonical" :: rest => (mode := Canonical; opts rest)
              | "-unchecked" :: rest => (mode := Unchecked; opts rest)
              | "-urs" :: rest => (urs := true; opts rest)
              | "-width" :: n :: rest => (case Int.fromString n of
                                              SOME w => (Format.width := w; opts rest)
                                            | NONE => usage ())
              | "-tabwidth" :: n :: rest => (case Int.fromString n of
                                                 SOME w => (Format.tabwidth := w; opts rest)
                                               | NONE => usage ())
              | "-help" :: _ => help ()
              | "--help" :: _ => help ()
              | "-h" :: _ => help ()
              | files =>
                (case List.find (String.isPrefix "-") files of
                     SOME a => (err ("urt format: no option called " ^ a ^ " (options go before the files)"); usage ())
                   | NONE => files)
        val files = opts args
        val statuses =
            case files of
                [] =>
                let
                    val name = if !urs then "stdin.urs" else "stdin.ur"
                    val src = readAll TextIO.stdIn
                in
                    case !mode of
                        InPlace => usage ()
                      | _ => [run (!mode) (name, Parse.parseText (name, src))]
                end
              | _ =>
                (* .urs files last: the lexer's handling of the "sig" prefix
                 * (see Parse) leaves state behind that would shift the
                 * positions of a .ur file parsed after it *)
                let
                    val (urs, ur) = List.partition (fn f => String.isSuffix ".urs" f) files
                in
                    map (fn f => run (!mode) (f, Parse.parseFile f)) (ur @ urs)
                end
    in
        foldl Int.max 0 statuses
    end
    handle e => (err ("urt format: uncaught exception " ^ General.exnMessage e); 2)

end

val _ = Posix.Process.exit (Word8.fromInt (Main.main (CommandLine.arguments ())))
