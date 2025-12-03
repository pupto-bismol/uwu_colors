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
          name = "uwu_colors";

          nativeBuildInputs = [
            clippy
          ];

          cargoLock.lockFile = ./Cargo.lock;
          src = lib.cleanSource ./.;
        }
      ) { inherit (pkgs.rustPlatform) buildRustPackage; };
    in
    {
      overlays = {
        default = final: prev: {
          uwu-colors = flakePackage prev;
        };
      };

      packages = forAllSystems (pkgs: {
        default = flakePackage pkgs;
      });

      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          program = nixpkgs.lib.getExe' (flakePackage pkgs) "uwu_colors";
        };
      });
    };
}
