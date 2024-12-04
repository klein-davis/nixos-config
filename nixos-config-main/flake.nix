{
  description = "My system configuration";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixpkgs-super-old.url = "github:nixos/nixpkgs/nixos-21.05";
    nixpkgs-old.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
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
      inputs.hyprland.follows = "hyprland";
    };
    hyprgrass = {
        url = "github:horriblename/hyprgrass";
        inputs.hyprland.follows = "hyprland"; # IMPORTANT
    };
  
    home-manager = {
      url = "github:nix-community/home-manager";
      #url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, nixpkgs-unstable, nixpkgs-main, nixpkgs-old, nixpkgs-super-old, home-manager, ... } @ inputs:
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
          enable-enterprise-wifi = true;
        };
        vm = {
          hostname = "NIXVM";
        };
        pi = {
          system = "aarch64-linux";
          # system = "armv7l-linux"; # For 3B and older
        };
	      desktop2 = {
          # enable-nvidia = true;
          # enable-rgb-lights = true;
          hostname = "DESKTOP-2";
        };


        default = {
          username = "nixuser";
          default-passwd = "password";
          system = "x86_64-linux";
          enable-nvidia = false;
          enable-rgb-lights = false;
          enable-auto-login = false;
          enable-ssh-access = true;
          enable-enterprise-wifi = false;
          power = {
            mobile = false;
          };
        };
      };

      mergeAttrs = lhs: rhs: nixpkgs.lib.attrsets.recursiveUpdate lhs rhs;

      pkgsBundle = sys : {
        pkgs-super-old = import nixpkgs-super-old {
          system = sys;
          config.allowUnfree = true;
        };
        pkgs-old = import nixpkgs-old {
          system = sys;
          config.allowUnfree = true;
        };
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
          modules = [(import ./hosts/desktop)];
          specialArgs = { host="desktop";
            myOptions = mergeAttrs myCOptions.default myCOptions.desktop;
            pkgsBundle = pkgsBundle (mergeAttrs myCOptions.default myCOptions.desktop).system;
            inherit self inputs; 
          };
        };
        laptop = nixpkgs.lib.nixosSystem {
          system = (mergeAttrs myCOptions.default myCOptions.laptop).system;
          modules = [(import ./hosts/laptop)];
          specialArgs = { host="laptop"; 
            myOptions = mergeAttrs myCOptions.default myCOptions.laptop;
            pkgsBundle = pkgsBundle (mergeAttrs myCOptions.default myCOptions.laptop).system;
            inherit self inputs; 
          };
        };
        vm = nixpkgs.lib.nixosSystem {
          system = (mergeAttrs myCOptions.default myCOptions.vm).system;
          modules = [(import ./hosts/vm)];
          specialArgs = { host="vm"; 
            myOptions = mergeAttrs myCOptions.default myCOptions.vm;
            pkgsBundle = pkgsBundle (mergeAttrs myCOptions.default myCOptions.vm).system;
            inherit self inputs; 
          };
        };
        pi = nixpkgs.lib.nixosSystem {
          system = (mergeAttrs myCOptions.default myCOptions.pi).system;
          modules = [(import ./hosts/pi)];
          specialArgs = { host="pi"; 
            myOptions = mergeAttrs myCOptions.default myCOptions.pi;
            pkgsBundle = pkgsBundle (mergeAttrs myCOptions.default myCOptions.pi).system;
            inherit self inputs; 
          };
        };
	desktop2 = nixpkgs.lib.nixosSystem {
          system = (mergeAttrs myCOptions.default myCOptions.desktop2).system;
          modules = [(import ./hosts/desktop2)];
          specialArgs = { host="desktop2";
            myOptions = mergeAttrs myCOptions.default myCOptions.desktop2;
            pkgsBundle = pkgsBundle (mergeAttrs myCOptions.default myCOptions.desktop2).system;
            inherit self inputs; 
          };
	};
      };
    };
}
