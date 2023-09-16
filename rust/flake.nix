{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs =
    { self
    , flake-utils
    , naersk
    , nixpkgs
    , treefmt-nix
    , rust-overlay
    ,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
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
        buildInputs = with pkgs; [ ];
      in
      rec {
        formatter = treefmtEval.config.build.wrapper;
        # For `nix build` & `nix run`:
        packages = {
          default = naersk'.buildPackage {
            pname = "rust-flake";
            version = "latest";

            src = ./.;
            doCheck = true; # `cargo test`

            buildInputs = buildInputs ++ (with pkgs; [ zlib ]);

            nativeBuildInputs = with pkgs; [ cmake pkg-config ];

            meta = with pkgs.lib; {
              description = "rust flake template";
              longDescription = '''';
              license = licenses.gpl3;
              mainProgram = "rust-flake";
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
            nativeBuildInputs = with pkgs; [ toolchain ];
          };
        };
        checks = {
          formatting = treefmtEval.config.build.check self;
          lint = packages.clippy;
        };
      }
    );
}
