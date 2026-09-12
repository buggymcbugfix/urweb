{ lib, stdenv }:

# The Ur/Web toolbox, built from the C beside this file by its Makefile,
# and checked by urt/check on the way.  ../shell.nix puts it on the PATH
# of the development shell.
stdenv.mkDerivation {
  pname = "urt";
  version = "0.1";

  # What git tracks under urt: the sources, the Makefile, the checks.
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.intersection (lib.fileset.gitTracked ../.) ./.;
  };

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  # The pty cases want python3 and are skipped without it; the rest run.
  doCheck = true;
  checkTarget = "check";

  installPhase = ''
    runHook preInstall
    install -D -m 755 urt "$out/bin/urt"
    runHook postInstall
  '';

  meta = {
    description = "The Ur/Web toolbox: snapshot tests of the compiler, and more to come";
    mainProgram = "urt";
    platforms = lib.platforms.unix;
  };
}
