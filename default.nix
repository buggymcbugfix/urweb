let
  pinnedNixpkgs = import (builtins.fetchTarball {
    url = https://releases.nixos.org/nixos/unstable/nixos-26.11pre1035164.753cc8a3a874/nixexprs.tar.xz;
    # Hash obtained using `nix-prefetch-url --unpack <url>`
    sha256 = "04qa7d57m4l4sny0lnrzmnm854xszv43sfnfgs51xzmc5akssg1y";
  }) {};
in
{pkgs ? pinnedNixpkgs}: pkgs.callPackage ./derivation.nix {}
