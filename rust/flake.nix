{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {
    self,
    flake-utils,
    naersk,
    nixpkgs,
    treefmt-nix,
    rust-overlay,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        cargo = builtins.fromTOML (builtins.readFile ./Cargo.toml);
        overlays = [(import rust-overlay)];
        pkgs = (import nixpkgs) {
          inherit system overlays;
        };
        toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

        naersk' = pkgs.callPackage naersk {
          cargo = toolchain;
          rustc = toolchain;
          clippy = toolchain;
        };
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        buildInputs = with pkgs; [];
      in rec {
        formatter = treefmtEval.config.build.wrapper;
        # For `nix build` & `nix run`:
        packages = {
          default = naersk'.buildPackage {
            pname = "${cargo.package.name}";
            version = "${cargo.package.version}";

            src = ./.;
            doCheck = true; # `cargo test`

            buildInputs = buildInputs ++ (with pkgs; [zlib]);

            nativeBuildInputs = with pkgs; [cmake pkg-config];

            meta = with pkgs.lib; {
              description = "${cargo.version.description}";
              license = licenses.gpl3;
              mainProgram = "${cargo.version.name}";
              # maintainers = with maintainers; [];
            };
          };
          clippy = naersk'.buildPackage {
            src = ./.;
            mode = "clippy";
            inherit buildInputs;
          };
        };

        # For `nix develop`:
        devShells = {
          default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [toolchain];
          };
        };
        checks = {
          # default = packages.default;
          formatting = treefmtEval.config.build.check self;
          lint = packages.clippy;
        };
      }
    );
}
