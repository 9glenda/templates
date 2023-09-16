{
  projectRootFile = "flake.nix";
  programs = {
    alejandra = {
      enable = true;
    };
    deadnix = {
      enable = true;
    };
    rustfmt = {
      enable = true;
    };
    mdformat = {
      enable = true;
    };
  };
}
