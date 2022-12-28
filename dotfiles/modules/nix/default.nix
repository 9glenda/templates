{ pkgs
, config
, lib
, ...
}:
with lib;
with builtins; {
  options.sys.nix = {
    flakes = mkOption {
      type = types.bool;
      default = true;
      description = "Enable nix flakes";
    };
  };

  imports = [ ./flakes.nix ];
}

