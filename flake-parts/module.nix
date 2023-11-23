# Largely inspired by:
# https://github.com/srid/proc-flake/blob/master/flake-module.nix
{ self, config, lib, flake-parts-lib, ... } @ args:
let
  inherit (flake-parts-lib)
    mkPerSystemOption;
  inherit (lib)
    types;

  inputs = args.config.ocaml-nix_inputs;
in
{
  options = {
    ocaml-nix._inputs = lib.mkOption {
      type = types.raw;
      internal = true;
    };
    perSystem = mkPerSystemOption
      ({ config, self', inputs', pkgs, system, ... }:
        let
          ocamlSubmodule = types.submodule {
            options = {
              packages = lib.mkOption {
                type = types.attrsOf projectSubmodule;
                description = lib.mdDoc ''
                '';
              };
            };
          };
          projectSubmodule = types.submodule (args@{ name, ... }: {
            options = {
              name = lib.mkOption {
                type = types.str;
                description = lib.mdDoc ''
                  name of the dune package
                '';
              };
              devPackages = lib.mkOption {
                type = types.attrsOf types.str;
                description = lib.mdDoc ''
                  development packages
                '';
              };

            };
            config =
              let
              in
              {
                devShell = pkgs.mkShell {
                  nativeBuildInputs = [ ];
                };
              };
          });
        in
        {
          options.ocaml = lib.mkOption {
            type = ocamlSubmodule;
            description = lib.mdDoc ''
              Ocaml module
            '';
          };
        });
  };
}
