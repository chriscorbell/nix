{
  description = "Unified Nix configuration for Chris's machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      ...
    }:
    let
      lib = nixpkgs.lib;

      mkNixos =
        system: modules:
        lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs self; };
          modules = modules ++ [
            {
              system.configurationRevision = self.rev or self.dirtyRev or null;
            }
          ];
        };

      mkDarwin =
        system: modules:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit inputs self; };
          modules = modules ++ [
            {
              system.configurationRevision = self.rev or self.dirtyRev or null;
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        devbox = mkNixos "x86_64-linux" [
          ./hosts/devbox
        ];

        docker = mkNixos "x86_64-linux" [
          ./hosts/docker
        ];

        oracle-vps = mkNixos "x86_64-linux" [
          ./hosts/oracle-vps
        ];
      };

      darwinConfigurations = {
        mbp = mkDarwin "aarch64-darwin" [
          ./hosts/mbp
        ];
      };

      formatter = lib.genAttrs [ "aarch64-darwin" "x86_64-linux" ] (
        system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style
      );
    };
}
