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
    my-nix-modules = {
      url = "git+file:./external/nix-modules";
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
      my-nix-modules,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      overlays = [
        nix-vscode-extensions.overlays.default

        my-nix-modules.overlays.default # adds pkgs.pbfmt

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
              home-manager.extraSpecialArgs = { inherit overlays inputs; };
              home-manager.backupFileExtension = "backup";
              home-manager.sharedModules = [
                mac-app-util.homeManagerModules.default
              ];
              home-manager.users.wes =
                { pkgs, ... }:
                {
                  nixpkgs.overlays = overlays;

                  imports = [
                    my-nix-modules.homeManagerModules.default
                    ./hosts/crackbookpro/home.nix
                  ];

                  custom.modules = {
                    auth0-cli.enable = true;
                    awscli2.enable = true;
                    bat.enable = true;
                    btop.enable = true;
                    bws.enable = true;
                    claude-code.enable = true;
                    dbeaver-bin.enable = true;
                    deno.enable = true;
                    docker.enable = true;
                    dotnet.enable = true;
                    eza.enable = true;
                    fastfetch.enable = true;
                    fd.enable = true;
                    ffmpeg_6-headless.enable = true;
                    fontconfig.enable = true;
                    fzf.enable = true;
                    getoptions.enable = true;
                    gh = {
                      enable = true;
                      settings.editor = "code --wait";
                      ghq.enable = true;
                      gcd = {
                        enable = true;
                        addCodeHelper = true;
                      };
                    };
                    git = {
                      enable = true;
                      user = {
                        name = "wesleythorsen1";
                        email = "wesley.thorsen@gmail.com";
                        signingkey = "FAE484F021AE49E5";
                      };
                      credentialHelper = "osxkeychain";
                    };
                    gnupg.enable = true;
                    golang.enable = true;
                    jq.enable = true;
                    jwt-cli.enable = true;
                    kubernetes-helm.enable = true;
                    mysql80.enable = true;
                    nerd-fonts = {
                      enable = true;
                      fonts = with pkgs.nerd-fonts; [
                        jetbrains-mono
                      ];
                    };
                    ngrok.enable = true;
                    nix-tree.enable = true;
                    nixd.enable = true;
                    nixfmt-rfc-style.enable = true;
                    nmap.enable = true;
                    pbfmt.enable = true;
                    pipes-rs.enable = true;
                    pnpm.enable = true;
                    postman.enable = true;
                    ripgrep.enable = true;
                    rsclock.enable = true;
                    sd.enable = true;
                    watch.enable = true;
                    wget.enable = true;
                    yank.enable = true;
                    zip.enable = true;

                    # disabled:
                    bitwarden-cli.enable = false;
                    bun.enable = false;
                    burpsuite.enable = false;
                    davinci-resolve.enable = false;
                    doppler.enable = false;
                    goose-cli.enable = false;
                    podman = {
                      enable = false;
                      enableDesktop = false;
                    };
                    sbcl.enable = false;
                    slack.enable = false;
                    terraform.enable = false;
                    zulu24.enable = false;
                  };
                };
            }
          ];
        };
      };
    };
}
