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
    ./nodejs
    ./open-faas
    # ./podman
    ./python3
    ./shell
    # ./thunderbird
    ./vscode
    ./wezterm
  ];

  config = {
    programs.home-manager.enable = true;

    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowUnfreePredicate = _: true;

    systemd.user.startServices = "sd-switch";

    fonts.fontconfig.enable = true;

    home = {
      stateVersion = "25.05";

      packages = with pkgs; [
        auth0-cli
        awscli2
        # bun
        # burpsuite
        claude-code
        # davinci-resolve
        dbeaver-bin
        deno
        docker
        # doppler
        fontconfig
        # goose-cli
        kubernetes-helm
        mysql80
        nerd-fonts.jetbrains-mono
        ngrok
        nix-tree
        nixd
        nixfmt-rfc-style
        pnpm
        postman
        # sbcl # LISP
        # slack
        # terraform
        # zulu24
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

    # openai = {
    #   enable = false;
    #   apiKeyFile = "${config.home.homeDirectory}/.config/openai/keys/default.key";
    # };
  };
}
