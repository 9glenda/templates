{
  projectRootFile = "Cargo.toml";
  programs = {
    alejandra.enable = true; # nix
    statix.enable = true; # nix static analysis
    deadnix.enable = true; # find dead nix code
    rustfmt.enable = true; # rust
    shellcheck.enable = true; # bash/shell
    taplo.enable = true; # toml
    yamlfmt.enable = true; # yaml
  };
}
