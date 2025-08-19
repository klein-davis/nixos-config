{
  description = "My system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs, ... }@inputs:

    let
      system = "x86_64-linux";
    in {

    # nixos - system hostname
    nixosConfigurations.backupbeast = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs system;
      };
      modules = [
        ./configuration.nix
      ];
    };

  };
}
