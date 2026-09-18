# urt format, the formatter, built from the compiler's sources in the
# tree this sits in: the grammar's productions, the lexer and a few helper
# modules come from there, nothing is hand-copied.  The compiler need not
# be built: the XML entity table is generated here the way the compiler's
# build does it.  mlton, mllex and mlyacc are all it takes (the compiler's
# nix-shell has them).

URWEB_SRC = ../../..

URWEB_FILES = errormsg.sig errormsg.sml utf8.sig utf8.sml search.sig search.sml \
              list_util.sig list_util.sml print.sig print.sml prim.sig prim.sml source.sml

ENTITIES = $(URWEB_SRC)/xml/xhtml-lat1.ent $(URWEB_SRC)/xml/xhtml-special.ent $(URWEB_SRC)/xml/xhtml-symbol.ent

all: urt-format

urweb/%: $(URWEB_SRC)/src/%
	mkdir -p urweb && cp $< $@

# the XML entity table, generated like the compiler's xml/entities.sml
urweb/entities: $(URWEB_SRC)/xml/parse.sml
	mkdir -p urweb && mlton -output $@ $<

urweb/entities.sml: urweb/entities $(ENTITIES)
	./urweb/entities $(ENTITIES) > $@

urweb.lex: $(URWEB_SRC)/src/urweb.lex
	cp $< $@

urweb.lex.sml: urweb.lex
	mllex $<

gen_grammar: gen_grammar.sml
	mlton -output $@ $<

# the CST grammar: upstream's productions, CST-building actions
cst.grm: $(URWEB_SRC)/src/urweb.grm gen_grammar
	./gen_grammar $< > $@

cst.grm.sig cst.grm.sml: cst.grm
	mlyacc $<

# the compiler's grammar and lexer as they are, under other names, for the
# semantic check
ast.grm: $(URWEB_SRC)/src/urweb.grm
	sed -e 's/UrwebLrValsFn/AstLrValsFn/' -e 's/^%name Urweb/%name Ast/' $< > $@

ast.grm.sig ast.grm.sml: ast.grm
	mlyacc $<

ast.lex: $(URWEB_SRC)/src/urweb.lex
	sed -e 's/UrwebLexFn/AstLexFn/' -e 's/Urweb_TOKENS/Ast_TOKENS/' $< > $@

ast.lex.sml: ast.lex
	mllex $<

urt-format: urt-format.mlb $(addprefix urweb/,$(URWEB_FILES)) urweb/entities.sml \
            cst.grm.sig cst.grm.sml urweb.lex.sml ast.grm.sig ast.grm.sml ast.lex.sml \
            cst.sml parse.sml source_eq.sml check.sml trivia.sml verbatim.sml doc.sml format.sml main.sml
	mlton -output $@ urt-format.mlb

clean:
	rm -rf urt-format gen_grammar urweb urweb.lex urweb.lex.sml \
	       cst.grm cst.grm.sig cst.grm.sml cst.grm.desc \
	       ast.grm ast.grm.sig ast.grm.sml ast.grm.desc ast.lex ast.lex.sml

.PHONY: all clean
