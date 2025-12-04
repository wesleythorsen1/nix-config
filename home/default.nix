{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.homeConfig = {
    nixConfigPath = lib.mkOption {
      type = lib.types.str;
      description = "Path to your flake-based Nix config directory (e.g. ~/repos/github.com/wesleythorsen/nix-config)";
      default = "${config.home.homeDirectory}/repos/github.com/wesleythorsen/nix-config";
    };
  };

  imports = [
    # All module imports handled via dendritic aspects now.
  ];

  config = {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowUnfreePredicate = _: true;

    systemd.user.startServices = "sd-switch";

    fonts.fontconfig.enable = true;

    programs = {
      home-manager.enable = true;

      yazi = {
        enable = true;
      };
    };

    home = {
      stateVersion = "25.05";

      packages = with pkgs; [
        android-tools
        auth0-cli
        awscli2
        bat
        btop
        bws
        claude-code
        dbeaver-bin
        deno
        docker
        fastfetch
        ffmpeg_6-headless
        fontconfig
        getoptions
        gnupg
        jq
        jwt-cli
        kubernetes-helm
        litecli
        miller
        mysql80
        nerd-fonts.jetbrains-mono
        ngrok
        nix-tree
        nixd
        nixfmt-rfc-style
        nmap
        pipes-rs
        pnpm
        postman
        ripgrep
        rsclock
        sd
        watch
        wget
        yank
        zip
        zstd
      ];
    };

    golang.enable = true;

  };
}
