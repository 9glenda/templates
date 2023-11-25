{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nci = {
      url = "github:yusdacra/nix-cargo-integration";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.parts.follows = "flake-parts";
      inputs.treefmt.follows = "treefmt-nix";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:semnix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };
  };

  outputs = inputs @ {
    flake-parts,
    nci,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      imports = [
        inputs.nci.flakeModule
        inputs.treefmt-nix.flakeModule
        inputs.pre-commit-hooks.flakeModule
      ];
      perSystem = {
        config,
        pkgs,
        self',
        ...
      }: let
        name = "example";
      in {
        treefmt = import ./treefmt.nix;
        pre-commit = let
          toFilter = ["yamlfmt"];
          filterFn = n: _v: (!builtins.elem n toFilter);
          treefmtFormatters = pkgs.lib.mapAttrs (_n: v: {inherit (v) enable;}) (pkgs.lib.filterAttrs filterFn (import ./treefmt.nix).programs);
        in {
          settings = {
            src = ./.;

            hooks =
              treefmtFormatters;
          };
        };

        nci = {
          projects = {
            ${name} = {
              path = ./.;
            };
          };
          crates = {
            ${name} = {
              export = true;
            };
          };
          toolchainConfig = ./rust-toolchain.toml;
        };
        packages = {
          default = self'.packages."${name}-release";
          toolchain = config.nci.toolchains.shell;
        };
        devShells.default = pkgs.mkShell {
          shellHook = ''
            ${config.pre-commit.installationScript}
          '';
          nativeBuildInputs = with pkgs; [
            config.nci.toolchains.shell
          ];
        };
        # packages.default = crateOutputs.packages.release;
      };
    };
}
