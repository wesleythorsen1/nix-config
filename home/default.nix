{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    # ./chromium
    ./dotnet
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
      l = "eza -l --git-ignore";
      lt = "eza -lT --git-ignore";
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
      eza
      glow
      gum
      jq
      kubernetes-helm
      # a71323f.nodejs_16
      neofetch
      nix-tree
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
