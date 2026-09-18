# urt format

A source formatter for Ur/Web, in the style of the warenwirtschaft
repository (STYLE.md): the program urt-format, which `urt format` (or
`urt fmt`) runs.

    urt format FILE...           format to stdout
    urt format -i FILE...        rewrite in place (only files that change)
    urt format -check FILE...    exit 1 if a file is not formatted (for CI)
    urt format < FILE            stdin to stdout (-urs: the input is a signature)
    options: -width N (0, the default: no limit), -tabwidth N (default 4:
             the columns a tab counts for the width limit, and the spaces
             that make one level in space-indented input; how wide an editor
             shows a tab is its own business, see urt/.editorconfig)

Every run parses its input and its output with the Ur/Web compiler's own
grammar and requires the two ASTs to be the same, modulo whitespace inside
XML text and `_LOC_`.  If they differ, nothing is written and the exit
status is 2 (that is a formatter bug).  A file that does not parse is left
alone with exit status 1.

## How it works

The compiler's parser (`src/urweb.grm`) desugars while it parses: `x + y`
becomes `Basis.plus x y`, XML becomes `Basis.join`/`Basis.tag` calls, `fun`
becomes `val rec`, parentheses and comments vanish.  So the compiler's AST
cannot be printed back as source.

`gen_grammar` takes the compiler's grammar and replaces every semantic
action with one that builds a concrete syntax tree (`cst.sml`): one node per
grammar alternative, one leaf per token, leaves carrying only their source
span.  Productions, precedences and conflict resolution are upstream's, so
the formatter accepts exactly what the compiler accepts, and regenerating
after an upstream grammar change is a `make`.  The lexer is the compiler's
`urweb.lex`, unmodified.  The text between tokens, whitespace and comments,
is the *trivia* (`trivia.sml`); comments attach to the token they precede,
or to the token they follow when on the same line.

`format.sml` is a set of layout rules keyed by grammar shape, e.g.
`"eterm : LET edecls IN eexp END"`, producing a Wadler-style document
(`doc.sml`) whose indentation unit is the tab.  A node with no rule is
printed as written, re-indented.

The compiler's grammar and lexer are also linked in unchanged, under other
names (`ast.grm`, `ast.lex`), for the check: `check.sml` parses the
canonical form of input and output with them and `source_eq.sml` compares
the two `Source` ASTs structurally, positions excluded.

## Build and checks

    make -C urt                # urt and urt-format; the formatter is built from
                               # the compiler's sources in the tree, which need
                               # not be built
    make -C urt check-format   # urt/tests/format/NAME.in.ur must format to
                               # NAME.out.ur, and that to itself (update-format
                               # rewrites the .out files: review the diff)
    make -C urt check-demo     # the same for every program under demo/
    make -C urt check-oracle   # cross-check with the real compiler binary,
                               # URWEB or bin/urweb: same parse, comments
                               # kept, idempotent
    urt format -verbatim FILE  # must reproduce FILE byte for byte
    urt format -shapes FILE    # which grammar shapes a file uses
    urt format -canonical FILE # the text the check parses
    urt format -unchecked FILE # format without the check (debugging)

Build inside the compiler's `nix-shell --pure`: only mlton, mllex and
mlyacc are needed.

## treefmt

    formatter.urweb = {
      command = "urt";
      options = [ "format" "-i" ];
      includes = [ "*.ur" "*.urs" ];
    };
