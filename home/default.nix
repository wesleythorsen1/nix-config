{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (pkgs) stdenv;
  
  nixApplyCommand = if stdenv.isDarwin then "darwin-rebuild switch" else "home-manager switch";
in{
  options.homeConfig = {
    nixConfigPath = lib.mkOption {
      type        = lib.types.str;
      description = "Path to your flake-based Nix config directory (e.g. ~/repos/wesleythorsen1/nix-config)";
      default     = "${config.home.homeDirectory}/repos/wesleythorsen1/nix-config";
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
      stateVersion = "24.11";

      sessionVariables = {
        EDITOR = "code";
      };

      sessionPath = [
        "$HOME/bin"
      ];

      shellAliases = {
        c = "clear";
        l = "eza -la";
        lt = "eza -laT -I=.git";
        v = "nvim";
        nix-apply = "${nixApplyCommand}";
        anc = "${nixApplyCommand} --flake ${config.homeConfig.nixConfigPath}"; # apply-nix-config
      };

      file = {
        ".nix-config" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.homeConfig.nixConfigPath}";
          recursive = true;
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
