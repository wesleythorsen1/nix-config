{
  config,
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

    home = {
      stateVersion = "25.05";
    };
  };
}
