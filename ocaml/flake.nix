{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    opam-nix = {
      url = "github:tweag/opam-nix";
      inputs.opam-repository.follows = "opam-repository";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
      inputs.opam2json.follows = "opam2json";
      inputs.opam-overlays.follows = "opam-overlays";
      inputs.mirage-opam-overlays.follows = "mirage-opam-overlays";
      inputs.flake-utils.follows = "flake-utils";
    };

    janestreet-opam-repository = {
      url = "github:janestreet/opam-repository";
      flake = false;
    };
    opam-repository = {
      url = "github:ocaml/opam-repository";
      flake = false;
    };
    mirage-opam-overlays = {
      url = "github:dune-universe/mirage-opam-overlays";
      flake = false;
    };
    opam-overlays = {
      url = "github:dune-universe/opam-overlays";
      flake = false;
    };
    opam2json = {
      url = "github:tweag/opam2json";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";

  };
  outputs = { self, flake-utils, opam-nix, nixpkgs, opam-repository, janestreet-opam-repository, ... }@inputs:
    # Don't forget to put the package name instead of `throw':
    let package = "nix_ocaml";
    in flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        on = opam-nix.lib.${system};
        repos = [ on.opamRepository janestreet-opam-repository ];
        devPackagesQuery = {
          ocaml-lsp-server = "1.16.2";
          ocamlformat = "0.26.1";
          utop = "2.13.1";
          ocamlfind = "1.9.6";
        };
        query = devPackagesQuery // {
          ocaml-base-compiler = "5.1.0";
        };
        scope = on.buildDuneProject
          {
            # inherit repos;
          } "${package}" ./.
          query;
        overlay = final: prev: {
          # You can add overrides here
          ${package} = prev.${package}.overrideAttrs (_: {
            # Prevent the ocaml dependencies from leaking into dependent environments
            doNixSupport = false;
          });
        };
        scope' = scope.overrideScope' overlay;
        # The main package containing the executable
        main = scope'.${package};
        # Packages from devPackagesQuery
        devPackages = builtins.attrValues
          (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope');
      in
      {
        legacyPackages = scope';

        packages.default = main;

        devShells.default = pkgs.mkShell {
          inputsFrom = [ main ];
          buildInputs = devPackages ++ [
          ];
        };
      });
}
