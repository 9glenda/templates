{
  description = "A simple Go package";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "github:Nixos/nixpkgs/nixpkgs-unstable";
  # flake compat
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };
  outputs = { self, nixpkgs, flake-compat }:
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
      packages = forAllSystems
        (system:
          let
            pkgs = nixpkgsFor.${system};
          in
          {
            dwm = (self: super: {
              dwm = super.dwm.overrideAttrs (oldAttrs: rec {
                src = ./.;
              });
            });

            nixosConfigurations.container = nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules =
                [
                  self.nixosModule
                  ({ pkgs, ... }: {
                    boot.isContainer = true;

                    # Let 'nixos-version --json' know about the Git revision
                    # of this flake.
                    system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

                    environment.systemPackages = [
                      self.packages.x86_64-linux.golang
                    ];
                    golang.systemd = {
                      enable = true;
                    };
                    networking.hostName = "golang";
                    services.getty.autologinUser = "root";
                  })
                ];
            };

            nixosModule = { config, lib, pkgs, ... }:
              with lib;
              let
                cfg = config.golang.systemd;
              in
              {
                options.golang.systemd = {
                  enable = mkEnableOption "Enables golang";
                };

                config = mkIf cfg.enable {
                  systemd.services."golang.golang" = {
                    wantedBy = [ "multi-user.target" ];

                    serviceConfig =
                      let pkg = forAllSystems (system: self.packages.${system}.golang);
                      in {
                        Restart = "on-failure";
                        ExecStart = "${self.packages.x86_64-linux.golang}/bin/golang";
                        DynamicUser = "yes";
                        RuntimeDirectory = "golang.golang";
                        RuntimeDirectoryMode = "0755";
                        StateDirectory = "golang.golang";
                        StateDirectoryMode = "0700";
                        CacheDirectory = "golang.golang";
                        CacheDirectoryMode = "0750";
                      };
                  };
                };

              };

            # `nix run`
            apps = forAllSystems (system: {
              default = {
                type = "app";
                program = "${self.packages.${system}.golang}/bin/golang";
              };
            });

            formatter = forAllSystems (system: nixpkgsFor.${system}.nixpkgs-fmt);

            devShells = forAllSystems (system: {
              default = nixpkgsFor.${system}.mkShell {
                packages = [
                  nixpkgsFor.${system}.go
                  self.packages.${system}.golang
                ];
              };
            });


            defaultPackage = forAllSystems (system: self.packages.${system}.golang);
          };
        }
