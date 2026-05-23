ACLOCAL_AMFLAGS = -I m4

BIN       = @BIN@
SRCLIB    = @SRCLIB@
INCLUDE   = @INCLUDE@
SITELISP  = @SITELISP@
VERSION   = @VERSION@
MLTONARGS = @MLTONARGS@

LIB_UR   = $(SRCLIB)/ur
LIB_C    = $(SRCLIB)/c
LIB_JS   = $(SRCLIB)/js

all-local: smlnj mlton

SUBDIRS = src/c

.PHONY: smlnj mlton mlton-tc test check-local

smlnj: src/urweb.cm xml/entities.sml
mlton: bin/urweb
mlton-tc: bin/urwebtc

clean-local:
	rm -f bin/urweb bin/urwebtc compiler.du src/urweb.mlton.* \
		src/urweb.cm src/urweb.mlb xml/parse xml/entities.sml
	rm -f demo/demo.exe
	rm -rf .cm src/.cm

src/urweb.cm: src/prefix.cm src/sources
	cat $^ | sed -e 's/$$(SRC)\///g' > $@

src/urweb.mlb: src/prefix.mlb src/sources src/suffix.mlb
	sed -e 's/^\(.*\).grm$$/$$(BUILD)\/\1.mlton.grm.sig:\1.mlton.grm.sml/' -e 'y/:/\n/' \
		-e 's/^\(.*\).lex$$/$$(BUILD)\/\1.mlton.lex.sml/' \
	$^ > $@

src/urweb.mlton.lex: src/urweb.lex
	cp $< $@
src/urweb.mlton.grm: src/urweb.grm
	cp $< $@

src/urweb.mlton.lex.sml: src/urweb.mlton.lex
	mllex $<

src/urweb.mlton.grm.sig src/urweb.mlton.grm.sml: src/urweb.mlton.grm
	mlyacc $<

MLTON = mlton

#ifdef DEBUG
#	MLTON += -const 'Exn.keepHistory true'
#endif

#ifdef PROFILE
#	MLTON += -profile $(PROFILE)
#endif

bin/urweb: src/compiler.mlb xml/entities.sml \
		src/urweb.mlb $(srcdir)/src/*.sig $(srcdir)/src/*.sml src/config.sml \
		src/urweb.mlton.lex.sml \
		src/urweb.mlton.grm.sig src/urweb.mlton.grm.sml
	mkdir -p bin
	$(MLTON) $(MLTONARGS) -mlb-path-var 'SRC $(abs_srcdir)/src' -mlb-path-var 'BUILD $(abs_builddir)/src' -output $@ $<
bin/urwebtc: src/compiler.mlb xml/entities.sml \
		src/urweb.mlb $(srcdir)/src/*.sig $(srcdir)/src/*.sml src/config.sml \
		src/urweb.mlton.lex.sml \
		src/urweb.mlton.grm.sig src/urweb.mlton.grm.sml
	mkdir -p bin
	$(MLTON) $(MLTONARGS) -prefer-abs-paths true -show-def-use compiler.du -stop tc -mlb-path-var 'SRC $(abs_srcdir)/src' -mlb-path-var 'BUILD $(abs_builddir)/src' -output $@ $<

xml/entities.sml: xml/parse xml/xhtml-lat1.ent xml/xhtml-special.ent xml/xhtml-symbol.ent
	$^ > $@

xml/parse: xml/parse.sml
	mkdir -p xml
	$(MLTON) $(MLTONARGS) -output $@ $<

install-exec-emacs:
if USE_EMACS
	mkdir -p $(DESTDIR)$(SITELISP)
	cp $(srcdir)/src/elisp/*.el $(DESTDIR)$(SITELISP)/
endif

install-exec-local-main:
	mkdir -p $(DESTDIR)$(BIN)
	install bin/urweb $(DESTDIR)$(BIN)/
	mkdir -p $(DESTDIR)$(LIB_UR)
	cp $(srcdir)/lib/ur/*.urs $(DESTDIR)$(LIB_UR)/
	cp $(srcdir)/lib/ur/*.ur $(DESTDIR)$(LIB_UR)/
	mkdir -p $(DESTDIR)$(LIB_JS)
	cp $(srcdir)/lib/js/*.js $(DESTDIR)$(LIB_JS)/
	mkdir -p $(DESTDIR)$(INCLUDE)
	cp $(srcdir)/include/urweb/*.h $(DESTDIR)$(INCLUDE)/

install-exec-local: install-exec-local-main install-exec-emacs
	-ldconfig

uninstall-emacs:
if USE_EMACS
	rm -f $(DESTDIR)$(SITELISP)/urweb-compat.el $(DESTDIR)$(SITELISP)/urweb-mode.el $(DESTDIR)$(SITELISP)/urweb-move.el \
		$(DESTDIR)$(SITELISP)/urweb-defs.el $(DESTDIR)$(SITELISP)/urweb-mode-startup.el $(DESTDIR)$(SITELISP)/urweb-util.el
endif

uninstall-local-main:
	rm -f $(DESTDIR)$(BIN)/urweb $(DESTDIR)$(LIB_UR)/basis.urs $(DESTDIR)$(LIB_UR)/char.urs $(DESTDIR)$(LIB_UR)/datetime.urs		\
		$(DESTDIR)$(LIB_UR)/listPair.urs $(DESTDIR)$(LIB_UR)/list.urs $(DESTDIR)$(LIB_UR)/monad.urs					\
		$(DESTDIR)$(LIB_UR)/option.urs $(DESTDIR)$(LIB_UR)/string.urs $(DESTDIR)$(LIB_UR)/top.urs $(DESTDIR)$(LIB_UR)/char.ur		\
		$(DESTDIR)$(LIB_UR)/datetime.ur $(DESTDIR)$(LIB_UR)/listPair.ur $(DESTDIR)$(LIB_UR)/list.ur $(DESTDIR)$(LIB_UR)/monad.ur	\
		$(DESTDIR)$(LIB_UR)/option.ur $(DESTDIR)$(LIB_UR)/string.ur $(DESTDIR)$(LIB_UR)/top.ur $(DESTDIR)$(LIB_JS)/urweb.js		\
		$(DESTDIR)$(INCLUDE)/config.h $(DESTDIR)$(INCLUDE)/queue.h $(DESTDIR)$(INCLUDE)/request.h $(DESTDIR)$(INCLUDE)/types.h		\
		$(DESTDIR)$(INCLUDE)/urweb.h $(DESTDIR)$(INCLUDE)/types_cpp.h $(DESTDIR)$(INCLUDE)/urweb_cpp.h

uninstall-local: uninstall-local-main uninstall-emacs

EXTRA_DIST = demo/prose demo/*.urs demo/*.ur demo/*.urp demo/more/prose demo/more/*.urs demo/more/*.ur demo/more/*.urp \
	doc/Makefile doc/*.tex doc/*.ur doc/LICENSE lib/js \
	lib/ur/*.urs lib/ur/*.ur xml/parse.sml xml/*.ent \
	src/coq src/*.sig src/*.sml src/*.mlb src/config.sml.in src/elisp src/*.cm src/sources src/*.grm src/*.lex \
	CHANGELOG LICENSE urweb.ebuild include/urweb/*.h tests/*.html

dist-hook:
	cd src; rm -f urweb.mlton.lex urweb.mlton.grm *.lex.* *.grm.*
	cd demo; rm -f demo.ur*
	cd demo/more; rm -f demo.ur*

check-local: bin/urweb
	@set -e; \
	pid=""; \
	dbfile=$$(mktemp); \
	cleanup() { \
		kill $$pid 2>/dev/null || true; \
		pid=""; \
		rm -f $$dbfile $$dbfile-shm $$dbfile-wal; \
	}; \
	setup() { \
		sqlite3 $$dbfile < demo/demo.sql; \
	}; \
	trap cleanup EXIT INT TERM; \
	\
	echo "Compiling demo.exe."; \
	bin/urweb -boot -noEmacs -dbms sqlite -db $$dbfile -demo /Demo demo; \
	\
	echo "Running IPv4 test."; \
	setup; \
	eval "$$(demo/demo.exe -a 127.0.0.1 -p 8000 -P 9000 -d3 3>&1 1>/dev/null)"; \
	[ "$$status" = 'OK' ] || { echo "demo.exe failed to start" >&2; exit 1; }; \
	curl -s "http://localhost:$$port/Demo/Hello/main" | diff tests/hello.html - || { echo "Test 'Hello' failed" >&2; exit 1; }; \
	curl -s "http://localhost:$$port/Demo/Crud1/create?A=1&B=2&C=3&D=4" | diff tests/crud1.html - || { echo "Test 'Crud1' failed" >&2; exit 1; }; \
	cleanup; \
	\
	echo "Running IPv6 test."; \
	setup; \
	eval "$$(demo/demo.exe -A ::1 -p 8000 -P 9000 -d3 3>&1 1>/dev/null)"; \
	[ "$$status" = 'OK' ] || { echo "demo.exe failed to start" >&2; exit 1; }; \
	curl -g -6 -s "http://[::1]:$$port/Demo/Hello/main" | diff tests/hello.html - || { echo "Test 'Hello' failed" >&2; exit 1; }; \
	curl -g -6 -s "http://[::1]:$$port/Demo/Crud1/create?A=1&B=2&C=3&D=4" | diff tests/crud1.html - || { echo "Test 'Crud1' failed" >&2; exit 1; }; \
	echo "Tests succeeded."
