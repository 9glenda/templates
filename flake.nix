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
      # version = "${builtins.substring 0 8 lastModifiedDate}-${self.shortRev or "dirty"}";

      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgsUnstable.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgsUnstable { inherit system; });
    in
    {
      templates = {

        golang = {
          path = ./golang;
          description = "A basic golang flake";
        };

        dotfiles = {
          path = ./dotfiles;
          description = "A basic dotfiles flake";
        };

        dwm-flake = {
          path = ./dwm-flake;
          description = "A basic dwm flake";
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
