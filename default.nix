let
  pinnedNixpkgs = import (builtins.fetchTarball {
    name = "pinned-nixpkgs-for-urweb-school";
    url = https://github.com/NixOS/nixpkgs/archive/25.05.tar.gz;
    # Hash obtained using `nix-prefetch-url --unpack <url>`
    sha256 = "10wn0l08j9lgqcw8177nh2ljrnxdrpri7bp0g7nvrsn9rkawvlbf";
  }) {};
in
{pkgs ? pinnedNixpkgs}: pkgs.callPackage ./derivation.nix {}
