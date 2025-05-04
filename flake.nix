{
  description = "nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-a71323f.url = "github:nixos/nixpkgs/a71323f68d4377d12c04a5410e214495ec598d4c";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
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
    ...
  } @ inputs: let
    inherit (self) outputs;
    
    unstable-overlay = final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = prev.system;
        config.allowUnfree = true;
      };
    };
    
    vscode-overlay = nix-vscode-extensions.overlays.default;

    a71323f-overlay = final: prev: {
      a71323f = import inputs.nixpkgs-a71323f {
        system = prev.system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [
          "nodejs-16.20.2"
        ];
      };
    };
  in {
    nixosConfigurations = {
      "bbetty" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./hosts/bbetty/configuration.nix
        ];
      };
    };

    darwinConfigurations = {
      crackbookpro = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";

        modules = [
          ./hosts/crackbookpro/darwin.nix

          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs    = true;
            home-manager.useUserPackages  = true;
            home-manager.users.wes        = import ./hosts/crackbookpro/home.nix;
          }
        ];
  
        specialArgs = { inherit inputs outputs unstable-overlay a71323f-overlay vscode-overlay; };
      };
    };
    
    homeConfigurations = {
      "wes@bbetty" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [
          { nixpkgs.overlays = [ unstable-overlay a71323f-overlay vscode-overlay ]; }
          ./hosts/bbetty/home.nix
        ];
      };

      "wthorsen@MacBookPro" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [
          { nixpkgs.overlays = [ unstable-overlay a71323f-overlay vscode-overlay ]; }
          ./hosts/homie/home.nix
        ];
      };
    };
  };
}
