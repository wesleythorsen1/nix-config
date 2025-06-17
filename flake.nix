{
  description = "nix config";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-25.05";
    };
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    # nixpkgs = {
    #   url = "github:nixos/nixpkgs/nixos-unstable";
    # };
    nixpkgs-a71323f = {
      url = "github:nixos/nixpkgs/a71323f68d4377d12c04a5410e214495ec598d4c";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-a71323f,
    home-manager,
    hyprland,
    nix-vscode-extensions,
    nix-darwin,
    mac-app-util,
    ...
  } @ inputs: let
    inherit (self) outputs;
    
    overlays = [
      nix-vscode-extensions.overlays.default

      (
        final: prev: let 
          unstable = import inputs.nixpkgs-unstable {
            inherit (prev) system;
            config.allowUnfree = true;
          };
        in {
          brave = unstable.brave;
          dbeaver-bin = unstable.dbeaver-bin;
          docker = unstable.docker;
          nodejs_20 = unstable.nodejs_20;
          postman = unstable.postman;
          slack = unstable.slack;
          thunderbird = unstable.thunderbird;
          vscode = unstable.vscode;
          podman = unstable.podman;
          podman-desktop = unstable.podman-desktop;
          # zoom-us = unstable.zoom-us;
        }
      )

      (
        final: prev: {
          nodejs_16 = (import inputs.nixpkgs-a71323f {
            inherit (prev) system;
            config.permittedInsecurePackages = [
              "nodejs-16.20.2"
            ];
          }).nodejs_16;
        }
      )
    ];
  in {
    darwinConfigurations = {
      crackbookpro = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";

        specialArgs = { inherit inputs outputs overlays; };

        modules = [
          ./hosts/crackbookpro/darwin.nix

          mac-app-util.darwinModules.default

          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.wes = import ./hosts/crackbookpro/home.nix;
            home-manager.sharedModules = [
              mac-app-util.homeManagerModules.default
            ];
          }
        ];
      };
    };
    
    nixosConfigurations = {
      "thinkpad" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs; };

        modules = [
          ./hosts/thinkpad/configuration.nix
        ];
      };
    };

    homeConfigurations = {
      "wes@thinkpad" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        # specialArgs = { inherit inputs outputs overlays; };
        extraSpecialArgs = { inherit inputs outputs overlays; };
        
        modules = [
          ./hosts/thinkpad/home.nix
        ];
      };
    };
  };
}
