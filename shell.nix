{ pkgs ? import ./nixpkgs.nix }:
let
  urweb = pkgs.callPackage ./derivation.nix { }; # your derivation
  inherit (pkgs) lib;
in
pkgs.mkShell {
  inputsFrom = [ urweb ];

  packages = with pkgs; [
    smlnj
    rlwrap
  ];

  shellHook = ''
    export DEVPREFIX="$PWD/out"

    export SQHEADER="${pkgs.sqlite.dev}/include/sqlite3.h"
    export PGHEADER="${pkgs.postgresql.dev}/include/libpq-fe.h"
    export ICU_INCLUDES="-I${pkgs.icu.dev}/include"
    export CC="${pkgs.gcc}/bin/gcc"
    export CCARGS="-I$DEVPREFIX/include \
      -L${lib.getLib pkgs.openssl}/lib \
      -L${pkgs.sqlite.out}/lib \
      -L${pkgs.postgresql.lib}/lib \
      -Wno-error=int-conversion"

    repl() {
      [ -x configure ] || ./autogen.sh || return
      [ -f Makefile ]  || ./configure --prefix="$DEVPREFIX" \
                            --with-openssl=${pkgs.openssl.dev} || return
      make -C src/c && make -C src/c install && make smlnj || return
      rlwrap -pgreen -- sml .init.sml "$@"
    }
  '';
}
