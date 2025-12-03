{
  description = "uwu_colors";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  nixConfig = {
    extra-substituters = [
      "https://kira.cachix.org/"
    ];

    extra-trusted-public-keys = [
      "kira.cachix.org-1:THBrq/BplPxOJnWnxCBMOeP03ReON+FUYZpiDTnZqwA="
    ];
  };

  outputs =
    { nixpkgs, systems, ... }:
    let
      forAllSystems = fn: nixpkgs.lib.genAttrs (import systems) (sys: fn nixpkgs.legacyPackages.${sys});

      flakePackage = pkgs: pkgs.callPackage (
        {
          lib,
          buildRustPackage,
          clippy,
        }:
        buildRustPackage {
          pname = "uwu-colors";
          version = "0.4.0";

          nativeBuildInputs = [
            clippy
          ];

          cargoLock.lockFile = ./Cargo.lock;
          src = lib.cleanSource ./.;
        }
      ) { inherit (pkgs.rustPlatform) buildRustPackage; };

      flakePackageOld = pkgs: (flakePackage pkgs).overrideAttrs {
        pname = "uwu_colors";
        postPatch = ''
          substituteInPlace ./Cargo.toml \
            --replace-fail "uwu-colors" "uwu_colors"
        '';
      };
    in
    {
      overlays = {
        default = final: prev: {
          uwu-colors = flakePackageOld prev;
        };
        uwu-colors = final: prev: {
          uwu-colors = flakePackage prev;
        };
      };

      packages = forAllSystems (pkgs: {
        default = flakePackageOld pkgs;
        uwu-colors = flakePackage pkgs;
      });

      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          program = nixpkgs.lib.getExe' (flakePackageOld pkgs) "uwu_colors";
        };
        uwu-colors = {
          type = "app";
          program = nixpkgs.lib.getExe' (flakePackage pkgs) "uwu-colors";
        };
      });
    };
}
