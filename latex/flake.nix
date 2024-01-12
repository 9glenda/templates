{
  description = "LaTeX Notes";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs @ { flake-parts
    , treefmt-nix
    , ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];
      imports = [
        treefmt-nix.flakeModule
      ];
      perSystem =
        { config
        , pkgs
        , self'
        , ...
        }:
        let
          tex = pkgs.texlive.combine {
            inherit (pkgs.texlive) scheme-full latex-bin latexmk;
          };

          mkPdf = { filename }:
            pkgs.stdenvNoCC.mkDerivation rec {
              name = "latex-document";
              src = ./.;
              buildInputs = [ pkgs.coreutils tex ];
              phases = [ "unpackPhase" "buildPhase" "installPhase" ];
              buildPhase = ''
                export PATH="${pkgs.lib.makeBinPath buildInputs}";
                mkdir -p .cache/texmf-var
                env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
                  latexmk -interaction=nonstopmode -pdf -lualatex \
                  ${name}.tex
              '';
              installPhase = ''
                mkdir -p $out
                cp ${name}.pdf $out
              '';
            };
          mkLatexFiles = { dir }:
            let
              filterdFiles = dir: pkgs.lib.filterAttrs (name: _: pkgs.lib.hasSuffix ".tex" name) (builtins.readDir dir);
            in
            pkgs.lib.mapAttrs' (name: _: pkgs.lib.nameValuePair (pkgs.lib.removeSuffix ".tex" name) (mkPdf { filename = pkgs.lib.removeSuffix ".tex" name; })) (filterdFiles dir);
        in
        {
          treefmt = import ./treefmt.nix;
          packages = {
            inherit tex;
          }
          // mkLatexFiles { dir = ./.; };
          devShells = {
            default = pkgs.mkShell {
              packages = [ self'.packages.tex ];
            };
          };
        };
    };
}
