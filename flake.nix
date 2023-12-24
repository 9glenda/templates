{
  description = "A collection of flake templates";


  inputs = {
    nixpkgsUnstable = {
      url = "nixpkgs/nixos-unstable";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs =
    inputs @ { self
    , nixpkgsUnstable
    , flake-compat
    ,
    }:

    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      forAllSystems = nixpkgsUnstable.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (system: import nixpkgsUnstable { inherit system; });

      mkTemplate = { path, description }: { path = builtins.path { path = ./example; filter = path: _: baseNameOf path != "flake.lock"; }; 
      inherit description; };

    in
    {
      templates = {
        golang-old = {
          path = ./golang-old;
          description = "A basic golang flake";
        };
        dotfiles = {
          path = ./dotfiles;
          description = "A basic dotfiles flake";
        };
        haskell = {
          path = ./haskell;
          description = "A basic flake for haskell development";
        };
        ocaml = {
          path = ./ocaml;
          description = "A basic flake for ocaml development";
        };
        dwm-flake = {
          path = ./dwm-flake;
          description = "A basic dwm flake";
        };

        latex = {
          path = ./latex;
          description = "latex notes template";
        };
        rust-parts = {
          path = ./rust-parts;
          description = "Rust flake using flake-parts and nix-cargo-intigration";
        };
        rust = {
          path = ./rust;
          description = "A basic rust flake";
        };

      };
      devShells = forAllSystems (system: {
        default = nixpkgsFor.${system}.mkShell {
          packages = with nixpkgsFor.${system}; [
            git
          ];
        };
      });
      defaultTemplate = self.templates.golang;
      formatter = forAllSystems (system: nixpkgsFor.${system}.nixpkgs-fmt);
    };
}
