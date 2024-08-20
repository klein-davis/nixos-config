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
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland"; # <- make sure this line is present for the plugin to work as intended
    };
  
    home-manager = {
      url = "github:nix-community/home-manager";
      #url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, nixpkgs-unstable, nixpkgs-main, home-manager, ... } @ inputs:

    let
      system = "x86_64-linux";
      myCOptions = {
        
        desktop = {
          enable-nvidia = true;
          enable-rgb-lights = true;
          hostname = "DESKTOP-GV1U8SC";
        };
        laptop = {
          hostname = "DESKTOP-SCSCNBU";
          power.mobile = true;
        };
        vm = {
          hostname = "NIXVM";
        };
        pi = {
          system = "aarch64-linux";
          # system = "armv7l-linux"; # For 3B and older
        };

        default = {
          username = "kleind";
          system = "x86_64-linux";
          enable-nvidia = false;
          enable-rgb-lights = false;
          enable-auto-login = true;
          enable-ssh-access = true;
          power = {
            mobile = false;
          };
        };
      };

      mergeAttrs = lhs: rhs: nixpkgs.lib.attrsets.recursiveUpdate lhs rhs;

      pkgsBundle = sys : {
        pkgs-stable = import nixpkgs-stable {
          system = sys;
          config.allowUnfree = true;
        };
        pkgs-unstable = import nixpkgs-unstable {
          system = sys;
          config.allowUnfree = true;
        };
        pkgs-main = import nixpkgs-main {
          system = sys;
          config.allowUnfree = true;
        };
      };
    in {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          system = (mergeAttrs myCOptions.default myCOptions.desktop).system;
          modules = [
            (import ./hosts/desktop)
            inputs.stylix.nixosModules.stylix];
          specialArgs = { host="desktop";
            myOptions = mergeAttrs myCOptions.default myCOptions.desktop;
            pkgsBundle = pkgsBundle (mergeAttrs myCOptions.default myCOptions.desktop).system;
            inherit self inputs; 
          };
        };
        laptop = nixpkgs.lib.nixosSystem {
          system = (mergeAttrs myCOptions.default myCOptions.laptop).system;
          modules = [
            (import ./hosts/laptop)
            inputs.stylix.nixosModules.stylix];
          specialArgs = { host="laptop"; 
            myOptions = mergeAttrs myCOptions.default myCOptions.laptop;
            pkgsBundle = pkgsBundle (mergeAttrs myCOptions.default myCOptions.laptop).system;
            inherit self inputs; 
          };
        };
        vm = nixpkgs.lib.nixosSystem {
          system = (mergeAttrs myCOptions.default myCOptions.vm).system;
          modules = [
            (import ./hosts/vm)
            inputs.stylix.nixosModules.stylix];
          specialArgs = { host="vm"; 
            myOptions = mergeAttrs myCOptions.default myCOptions.vm;
            pkgsBundle = pkgsBundle (mergeAttrs myCOptions.default myCOptions.vm).system;
            inherit self inputs; 
          };
        };
        pi = nixpkgs.lib.nixosSystem {
          system = (mergeAttrs myCOptions.default myCOptions.pi).system;
          modules = [
            (import ./hosts/pi)
            inputs.stylix.nixosModules.stylix];
          specialArgs = { host="pi"; 
            myOptions = mergeAttrs myCOptions.default myCOptions.pi;
            pkgsBundle = pkgsBundle (mergeAttrs myCOptions.default myCOptions.pi).system;
            inherit self inputs; 
          };
        };
      };
    };
}
