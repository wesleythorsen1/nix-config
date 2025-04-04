{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    # ./chromium
    ./fd
    ./fzf
    ./git
    ./nvim
    ./oh-my-zsh
    ./tree
    # ./vscode
    ./wezterm
    ./zsh
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;

  systemd.user.startServices = "sd-switch";

  home = {
    sessionVariables = {
      EDITOR = "code";
    };

    sessionPath = [
      "$HOME/bin"
    ];

    shellAliases = {
      la = "ls -la";
      v = "nvim";
      hm = "home-manager";
      hms = "home-manager switch --flake ~/nix";
    };

    packages = with pkgs; [
      awscli2
      btop
      deno
      docker
      doppler
      git
      gum
      neofetch
      jq
      # a71323f.nodejs_16
      nodejs_20
      pipes-rs
      ripgrep
      rsclock
      # terraform
      wget
      yank
      yazi
      zip
    ];
  };
}
