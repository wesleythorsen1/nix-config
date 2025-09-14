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
      description = "Path to your flake-based Nix config directory (e.g. ~/repos/github.com/wesleythorsen1/nix-config)";
      default = "${config.home.homeDirectory}/repos/github.com/wesleythorsen1/nix-config";
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
    ./gh
    ./git
    ./nodejs
    ./nvim
    ./openai
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
        auth0-cli
        awscli2
        bat
        btop
        bun
        # burpsuite
        claude-code
        # davinci-resolve
        dbeaver-bin
        deno
        docker
        doppler
        eza
        ffmpeg_6-headless
        getoptions
        glow
        gnupg
        goose-cli
        gum
        jq
        jwt-cli
        kubernetes-helm
        mysql80
        fastfetch
        ngrok
        nix-tree
        nixd
        nixfmt-rfc-style
        # nodejs_20
        pipes-rs
        pnpm
        postman
        ripgrep
        rsclock
        sbcl
        slack
        # terraform
        watch
        wget
        yank
        yazi
        zip
        # zoom-us
        zulu24
      ];
    };

    gh = {
      enable = true;

      settings = {
        git_protocol = "https";
        editor = "code --wait";
        prompt = "enabled";
        prefer_editor_prompt = "disabled";
      };

      aliases = {
        prco = "pr checkout";
        prv = "pr view";
        prc = "pr create";
      };

      ghq = {
        enable = true;
        root = "${config.home.homeDirectory}/repos";
        useEnvVar = true;
      };

      gcd = {
        enable = true;
        addCodeHelper = true;
      };
    };

    openai = {
      enable = true;
      voiceCommands.enable = true;
      voiceToText.enable = true;
      apiKeyFile = "${config.home.homeDirectory}/.config/openai/keys/default.key";
    };
  };
}
