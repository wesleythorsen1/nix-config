{ config, pkgs, ... }:

{
  home.username = "wes";
  homeDirectory = "/home/wes";
  home.homeDirectory = "/home/wes"; # ?

  programs.git.userName  = "wesleythorsen1";
  programs.git.userEmail = "wesley.thorsen@gmail.com";
  programs.git.extraConfig.credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";

  homeConfig.nixBuildTool  = "nixos-rebuild";
  homeConfig.nixConfigPath = "${config.home.homeDirectory}/nix-config";
  homeConfig.hostName  = "bbetty";

  imports = [
    ../../home
    ../../home/wayland
  ];

  home.packages = with pkgs; [
    vlc
    wl-clipboard
  ];
}
