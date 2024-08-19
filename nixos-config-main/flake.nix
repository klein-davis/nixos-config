{
  description = "My system configuration";

  inputs = {

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-main.url = "github:NixOS/nixpkgs";

    stylix.url = "github:danth/stylix";

    #nur.url = "github:nix-community/NUR";
  
    hypr-contrib.url = "github:hyprwm/contrib";
    hyprpicker.url = "github:hyprwm/hyprpicker";
  
    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
  
    #nix-gaming.url = "github:fufexan/nix-gaming";
  
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  
    home-manager = {
      url = "github:nix-community/home-manager";
      #url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, nixpkgs-unstable, nixpkgs-main, home-manager, ... } @ inputs:

    let
      username = "kleind";
      system = "x86_64-linux";
      myCOptions = {
        desktop = {
          enable-nvidia = true;
          enable-rgb-lights = true;
          hostname = "DESKTOP-GV1U8SC";
          enable-auto-login = true;
          enable-ssh-access = true;
        };
        laptop = {
          enable-nvidia = false;
          enable-rgb-lights = true;
          hostname = "DESKTOP-SCSCNBU";
          enable-auto-login = true;
          enable-ssh-access = true;
        };
        vm = {
          enable-nvidia = false;
          enable-rgb-lights = false;
          hostname = "NIXVM";
          enable-auto-login = true;
          enable-ssh-access = true;
        };
      };

      pkgs-stable = import nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
      pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      pkgs-main = import nixpkgs-main {
          inherit system;
          config.allowUnfree = true;
        };
    in {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (import ./hosts/desktop)
            inputs.stylix.nixosModules.stylix];
          specialArgs = { host="desktop"; myOptions = myCOptions.desktop; inherit self inputs username pkgs-stable pkgs-main pkgs-unstable; };
        };
        laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (import ./hosts/laptop)
            inputs.stylix.nixosModules.stylix];
          specialArgs = { host="laptop"; myOptions = myCOptions.laptop;  inherit self inputs username pkgs-stable pkgs-main pkgs-unstable; };
        };
        vm = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (import ./hosts/vm)
            inputs.stylix.nixosModules.stylix];
          specialArgs = { host="vm"; myOptions = myCOptions.laptop; inherit self inputs username pkgs-stable pkgs-main pkgs-unstable; };
        };
      };

      #homeConfigurations.nixuser = home-manager.lib.homeManagerConfiguration {
      #  pkgs = nixpkgs.legacyPackages.${system};
      #  modules = [ ./home-manager/home.nix ];
      #};
    };
}
