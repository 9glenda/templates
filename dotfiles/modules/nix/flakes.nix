{ pkgs
, config
, lib
, ...
}:
with lib;
with builtins; let
  cfg = config.sys.nix;
in
{
  config = mkIf cfg.flakes {
    nix = {
      #package = pkgs.nixFlakes;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };
  };
}

