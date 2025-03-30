{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    ../../home

    # ../../home/starship
    ../../home/chromium
    ../../home/vscode
    ../../home/wayland
  ];
  
  home.username = "wes";
  homeDirectory = "/home/wes";

  programs.git.userName  = "wesleythorsen1";
  programs.git.userEmail = "wesley.thorsen@gmail.com";
  programs.git.extraConfig.credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";

  packages = with pkgs; [
    vlc
    wl-clipboard
  ];
}
