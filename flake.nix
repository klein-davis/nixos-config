{
  description = "My system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-super-old.url = "github:nixos/nixpkgs/nixos-21.05";
    nixpkgs-old.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-main.url = "github:NixOS/nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    alejandra.url = "github:kamadorueda/alejandra/3.0.0";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    flake-utils.url = "github:numtide/flake-utils";

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=v0.6.0";
      follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      # url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland Inputs
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # hyprland-plugins = {
    #   url = "github:hyprwm/hyprland-plugins";
    #   inputs.hyprland.follows = "hyprland";
    # };
    hypr-contrib.url = "github:hyprwm/contrib";
    hyprpicker.url = "github:hyprwm/hyprpicker";
    # hyprgrass = {
    #     url = "github:horriblename/hyprgrass";
    #     inputs.hyprland.follows = "hyprland"; # IMPORTANT
    # };
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };

    stylix = {
      url =  "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nur.url = "github:nix-community/NUR";

    #nix-gaming.url = "github:fufexan/nix-gaming";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = { 
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, ... } @ inputs:
    let
      system = "x86_64-linux";
      myCOptions = {
        desktop = {
          enable-nvidia-gpu = true;
          enable-rgb-lights = true;
          hostname = "DESKTOP-GV1U8SC";
          enable-auto-login = true;
          screens = [
            # Left Tall
            "DP-3, 1920x1200@60, 0x0, 1"

            # Middle
            "DP-2, 1920x1080@120, 1920x120, 1"

            # Right Tall
            "DP-1, 1920x1200@60, 3840x0, 1"

            # TV
            "HDMI-A-1, 3840x2160@59, 5760x0, 2"
          ];
        };
        framework1 = {
          hostname = "LAPTOP-PDQ3S7";
          power.mobile = true;
          enable-amd-cpu = true;
          enable-amd-gpu = true;
          # enable-enterprise-wifi = true;
          enable-auto-login = true;
          screens = [ "eDP-2, 2560x1600@165, 0x0, 1.25"];
          # prefered-gpu.enable = true;
          # prefered-gpu.path = "/dev/dri/by-path/renderD129";
        };
        laptop = {
          hostname = "DESKTOP-SCSCNBU";
          power.mobile = true;
          enable-enterprise-wifi = true;
        };
        vm = {
          hostname = "NIXVM";
          enable-auto-login = true;
        };
        pi = {
          system = "aarch64-linux";
          # system = "armv7l-linux"; # For 3B and older
        };
	      desktop2 = {
          # enable-nvidia-gpu = true;
          # enable-rgb-lights = true;
          hostname = "DESKTOP-2";
        };


        default = {
          # config-name = "default";
          username = "nixuser";
          default-passwd = "password";
          system = "x86_64-linux";
          enable-intel-cpu = false;
          enable-amd-cpu = false;
          enable-nvidia-gpu = false;
          enable-amd-gpu = false;
          enable-rgb-lights = false;
          enable-auto-login = false;
          enable-ssh-access = true;
          enable-enterprise-wifi = false;
          virtualization = true;
          screens = [ ];
          prefered-gpu = {
            enable = false;
            # Found with 
            # lspci -k | grep -E '0300:|0380:|0302:' -B1 -A2
            # ls -l /dev/dri/by-path/ looking for render for dGPU
            path = "";
          };
          power = {
            mobile = false;
          };
        };
      };

      mergeAttrs = lhs: rhs: nixpkgs.lib.attrsets.recursiveUpdate lhs rhs;

      pkgsBundle = sys : {
        pkgs-super-old = import inputs.nixpkgs-super-old {
          system = sys;
          config.allowUnfree = true;
        };
        pkgs-old = import inputs.nixpkgs-old {
          system = sys;
          config.allowUnfree = true;
        };
        pkgs-stable = import inputs.nixpkgs-stable {
          system = sys;
          config.allowUnfree = true;
        };
        pkgs-unstable = import inputs.nixpkgs-unstable {
          system = sys;
          config.allowUnfree = true;
        };
        pkgs-main = import inputs.nixpkgs-main {
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
            # pkgsBundle = myOptions.system;
            inherit self inputs; 
          };
        };
        framework1 = nixpkgs.lib.nixosSystem {
          system = (mergeAttrs myCOptions.default myCOptions.framework1).system;
          modules = [(import ./hosts/framework1)  nixos-hardware.nixosModules.framework-16-7040-amd];
          specialArgs = { host="framework1"; 
            myOptions = mergeAttrs myCOptions.default myCOptions.framework1;
            pkgsBundle = pkgsBundle (mergeAttrs myCOptions.default myCOptions.framework1).system;
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
