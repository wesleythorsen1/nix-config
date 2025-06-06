{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.homeConfig = {
    nixBuildTool = lib.mkOption {
      type        = lib.types.str;
      description = "Command to rebuild/reload your Nix config (e.g. darwin-rebuild or nixos-rebuild)";
      default     = throw "Error: homeConfig.buildTool must be set in your configuration.";
    };

    nixConfigPath = lib.mkOption {
      type        = lib.types.str;
      description = "Path to your flake-based Nix config directory (e.g. $HOME/nix-config)";
      default     = throw "Error: homeConfig.nixConfigPath must be set in your configuration.";
    };

    hostName = lib.mkOption {
      type        = lib.types.str;
      description = "System host name, same as config.networking.hostName";
      default     = throw "Error: homeConfig.hostName must be set in your configuration.";
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
        switch = "${config.homeConfig.nixBuildTool} switch --flake ${config.homeConfig.nixConfigPath}#${config.homeConfig.hostName}";
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
