{
  description = "ocaml module for flake-parts";
  outputs = { self, ... } @ inp: {
    flakeModule = {
      imports = [ ./module.nix ];
      config = {
        ocaml-nix._inputs = {
          inherit (inp) crane dream2nix rust-overlay;
        };
      };
    };
  };
}
