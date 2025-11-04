{
  description = "nix config";

  inputs = {
    # nixpkgs = {
    #   url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";
    # };
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
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
    wesleythorsen1-nix-modules = {
      url = "github:wesleythorsen1/nix-modules";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      self,
      nixpkgs-unstable,
      home-manager,
      nix-vscode-extensions,
      nix-darwin,
      mac-app-util,
      wesleythorsen1-nix-modules,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      overlays = [
        nix-vscode-extensions.overlays.default

        (
          final: prev:
          let
            unstable = import nixpkgs-unstable {
              inherit (prev) system;
              config.allowUnfree = true;
            };
          in
          {
            brave = unstable.brave;
            dbeaver-bin = unstable.dbeaver-bin;
            docker = unstable.docker;
            postman = unstable.postman;
            slack = unstable.slack;
            thunderbird = unstable.thunderbird;
            vscode = unstable.vscode;
            podman = unstable.podman;
            podman-desktop = unstable.podman-desktop;
            # zoom-us = unstable.zoom-us;
          }
        )
      ];
    in
    {
      darwinConfigurations = {
        crackbookpro = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";

          pkgs = import nixpkgs-unstable {
            system = "aarch64-darwin";
            overlays = overlays;
            config.allowUnfree = true;
          };

          specialArgs = { inherit inputs outputs overlays; };

          modules = [
            ./hosts/crackbookpro/darwin.nix

            mac-app-util.darwinModules.default

            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.users.wes =
                { ... }:
                {
                  imports = [
                    wesleythorsen1-nix-modules.homeManagerModules.default
                    ./hosts/crackbookpro/home.nix
                  ];

                  custom.enable = true;
                  custom.modules = {
                    golang.enable = true;
                    dotnet.enable = true;
                    fd.enable = true;
                  };
                };
              home-manager.extraSpecialArgs = { inherit overlays inputs; };
              home-manager.backupFileExtension = "backup";
              home-manager.sharedModules = [
                mac-app-util.homeManagerModules.default
              ];
            }
          ];
        };
      };
    };
}
