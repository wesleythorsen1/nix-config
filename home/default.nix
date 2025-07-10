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
      description = "Path to your flake-based Nix config directory (e.g. ~/code/wesleythorsen1/nix-config)";
      default = "${config.home.homeDirectory}/code/wesleythorsen1/nix-config";
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
    # ./podman
    ./python3
    ./shell
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

      packages = with pkgs; [
        awscli2
        btop
        # burpsuite
        # davinci-resolve
        dbeaver-bin
        deno
        docker
        doppler
        eza
        gh
        glow
        gnupg
        goose-cli
        gum
        jq
        kubernetes-helm
        mysql80
        neofetch
        ngrok
        nix-tree
        nixd
        nixfmt-rfc-style
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
        # zoom-us
        zulu24
      ];
    };
  };
}
