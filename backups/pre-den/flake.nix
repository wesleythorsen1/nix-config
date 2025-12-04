{
  description = "nix config (dendritic-style flake-parts layout for crackbookpro/wes)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./modules/systems.nix
        ./modules/overlays.nix
        ./modules/features/git.nix
        ./modules/features/shell.nix
        ./modules/features/tree.nix
        ./modules/home/wes.nix
        ./modules/hosts/crackbookpro.nix
        ./modules/home-configs.nix
        ./modules/darwin-configs.nix
      ];
    };
}
