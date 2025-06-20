{
  inputs,
  config,
  pkgs,
  overlays,
  ...
}:

{
  nixpkgs.overlays = overlays;

  home.username = "wes";
  home.homeDirectory = "/home/wes";

  programs.git.userName = "wesleythorsen1";
  programs.git.userEmail = "wesley.thorsen@gmail.com";
  programs.git.extraConfig.credential.helper = "${
    pkgs.git.override { withLibsecret = true; }
  }/bin/git-credential-libsecret";

  imports = [
    ../../home
    ../../home/hyprland
    ../../home/waybar
  ];

  home.packages = with pkgs; [
    googleearth-pro
    vlc
    wl-clipboard
    wofi
  ];
}
