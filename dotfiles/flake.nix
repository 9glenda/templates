{
  description = "My nix system config";

  inputs = {
    nixpkgsUnstable = {
      url = "nixpkgs/nixos-unstable";
    };
    # The master branch of the NixOS/nixpkgs repository on GitHub.
    nixpkgsGitHub = {
      url = "github:NixOS/nixpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgsUnstable";
    };
  };

  outputs =
    inputs @ { self
    , nixpkgsUnstable
    , nixpkgsGitHub
    , flake-compat
    , home-manager
    ,
    }:
    let
      # System types to support.
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgsUnstable.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgsUnstable { inherit system; });

      systemFor = forAllSystems (system: { inherit system; });

      modulesMain = import ./configs/main;

    in
    {
      formatter = forAllSystems (system: nixpkgsFor.${system}.nixpkgs-fmt);

      devShells = forAllSystems (system: {
        default = nixpkgsFor.${system}.mkShell {
          packages = with nixpkgsFor.${system}; [
            git
            colmena
          ];
          NIX_CONFIG = "experimental-features = nix-command flakes";
        };
      });

      nixosConfigurations = {
        main_x86_64-linux = nixpkgsUnstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules =
            [
              #home-manager.nixosModules.home-manager
              modulesMain
            ];
        };
        main_aarch64-linux = nixpkgsUnstable {
          system = "aarch64-linux";
          modules = [
            home-manager.nixosModules.home-manager
            modulesMain
          ];
        };
      };
      colmena = {
        meta = {
          nixpkgs = nixpkgsFor.x86_64-linux;
        };

        main = import ./configs/main/colmena.nix;
        #deployment.allowLocalDeployment = true;
      };
    };
}

