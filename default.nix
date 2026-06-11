let
  pinnedNixpkgs = import (builtins.fetchTarball {
    name = "pinned-nixpkgs-for-urweb-school";
    url = https://github.com/NixOS/nixpkgs/archive/25.05.tar.gz;
    # Hash obtained using `nix-prefetch-url --unpack <url>`
    sha256 = "1915r28xc4znrh2vf4rrjnxldw2imysz819gzhk9qlrkqanmfsxd";
  }) {};
in
{pkgs ? pinnedNixpkgs}: pkgs.callPackage ./derivation.nix {}
