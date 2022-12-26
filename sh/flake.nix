{
  description = "A simple Go package";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "github:Nixos/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let

      # to work with older version of flakes
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      # Generate a user-friendly version number.
      version = builtins.substring 0 8 lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in
    {

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          hello = pkgs.stdenv.mkDerivation {
            pname = "hello";
            inherit version;
            # In 'nix develop', we don't need a copy of the source tree
            # in the Nix store.
            src = ./.;
            unpackPhase = ":";
            installPhase =
            ''
              mkdir -p $out/bin
              install main.sh $out/bin/
            '';
          };
        });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.hello}/bin/hello";
        };
      });

      formatter = forAllSystems (system: nixpkgsFor.${system}.nixpkgs-fmt);

      devShells = forAllSystems (system: {
        default = nixpkgsFor.${system}.mkShell {
          packages = [
            nixpkgsFor.${system}.shellcheck
            self.packages.${system}.hello
          ];
        };
      });


      defaultPackage = forAllSystems (system: self.packages.${system}.hello);
    };
}
