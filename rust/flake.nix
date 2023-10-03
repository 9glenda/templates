{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    rust-overlay.url = "github:oxalica/rust-overlay";
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    crane,
    nixpkgs,
    treefmt-nix,
    rust-overlay,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      # imports = [
      #   inputs.treefmt-nix.flakeModule
      # ];
      systems = nixpkgs.lib.systems.flakeExposed;
      perSystem = {
        pkgs,
        system,
        ...
      }: let
        cargo = builtins.fromTOML (builtins.readFile ./Cargo.toml);
        overlays = [(import rust-overlay)];
        pkgs = (import nixpkgs) {
          inherit system overlays;
        };
        inherit (pkgs) lib;
        toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

        craneLib = (crane.mkLib pkgs).overrideToolchain toolchain;

        src = craneLib.cleanCargoSource (craneLib.path ./.);

        commonArgs = {
          inherit src;

          buildInputs = with pkgs; [
            zlib
            git
          ];
        };

        cargoArtifacts = craneLib.buildDepsOnly commonArgs;
        cargoPlugins = with pkgs; [
          cargo-expand
          cargo-modules
          cargo-nextest
          cargo-watch
          # cargo-criterion
          # cargo-llvm-cov
          bacon
        ];
      in rec {
        formatter = treefmtEval.config.build.wrapper;
        packages = {
          default = craneLib.buildPackage (commonArgs
            // rec {
              inherit cargoArtifacts;
              pname = "${cargo.package.name}";
              version = "${cargo.package.version}";

              # doNotLinkInheritedArtifacts = true;
              meta = with pkgs.lib; {
                description = "${cargo.package.description}";
                homepage = "${cargo.package.repository}";
                license = licenses.gpl3;
                mainProgram = "${cargo.package.name}";
                maintainers = with maintainers; [_9glenda];
              };
            });
        };
        # For `nix develop`:
        devShells = {
          default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [toolchain cargoPlugins];
          };
        };
        checks = {
          formatting = treefmtEval.config.build.check self;
        };
      };
    };
  # flake-utils.lib.eachDefaultSystem (
  #   system: let
  #   in rec {
  #   }
  # );
}
