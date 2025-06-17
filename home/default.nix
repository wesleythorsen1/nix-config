{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (pkgs) stdenv;
  
  activationCommand = if stdenv.isDarwin then "darwin-rebuild switch" else "home-manager switch";
in {
  options.homeConfig = {
    nixConfigPath = lib.mkOption {
      type        = lib.types.str;
      description = "Path to your flake-based Nix config directory (e.g. ~/code/wesleythorsen1/nix-config)";
      default     = "${config.home.homeDirectory}/code/wesleythorsen1/nix-config";
    };
  };

  imports = [
    ./accounts/email
    ./accounts/email/personal
    ./accounts/email/take2

    ./chromium
    ./dotnet
    ./fd
    ./fzf
    ./git
    ./nodejs
    ./nvim
    ./oh-my-zsh
    # ./podman
    ./python3
    # ./thunderbird
    ./tree
    ./vscode
    ./wezterm
    ./zsh
  ];

  config = {
    programs.home-manager.enable = true;

    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowUnfreePredicate = _: true;

    systemd.user.startServices = "sd-switch";

    home = {
      stateVersion = "25.05";

      sessionVariables = {
        EDITOR = "code";
        NIX_ACTIVE_CONFIG_DIR = "${config.homeConfig.nixConfigPath}";
      };

      sessionPath = [
        "${config.home.homeDirectory}/bin"
      ];

      shellAliases = {
        c = "clear";
        l = "eza -la";
        lt = "eza -laT -I=.git";
        v = "nvim";
        na = "nix-activate"; # see "bin/nix-activate" script below
      };

      file = {
        ".nix-config" = {
          # symlink "~/.nix-config" to physical repo location
          source = config.lib.file.mkOutOfStoreSymlink "${config.homeConfig.nixConfigPath}";
          recursive = true;
        };
        "bin/nix-activate" = {
          # usage:
          #   `nix-activate`                            - defaults to $NIX_ACTIVE_CONFIG_DIR if set, otherwise last value of ${config.homeConfig.nixConfigPath}
          #   `nix-activate ./nix/config/dir#host@user` - with path (hostname and username optional, default to current)
          executable = true;
          text = ''
            #!/usr/bin/env bash
            flakePath="''${1:-''${NIX_ACTIVE_CONFIG_DIR:-${config.homeConfig.nixConfigPath}}}"
            exec sudo ${activationCommand} --flake "$flakePath"
          '';
        };
      };

      packages = with pkgs; [
        awscli2
        btop
        dbeaver-bin
        deno
        docker
        doppler
        eza
        gh
        glow
        gum
        jq
        kubernetes-helm
        mysql80
        neofetch
        ngrok
        nix-tree
        # nodejs_20
        pipes-rs
        postman
        ripgrep
        rsclock
        slack
        # terraform
        wget
        yank
        yazi
        zip
        zoom-us
      ];
    };
  };
}
