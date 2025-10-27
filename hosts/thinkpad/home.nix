{
  pkgs,
  overlays,
  ...
}:

{
  nixpkgs.overlays = overlays;

  home.username = "wes";
  home.homeDirectory = "/home/wes";

  programs.git.settings = {
    user = {
      name = "wesleythorsen1";
      email = "wesley.thorsen@gmail.com";
    };
    credential.helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
  };

  imports = [
    ../../home
    # ../../home/hyprland
    # ../../home/waybar
  ];

  home.packages = with pkgs; [
    # googleearth-pro
    vlc
    wl-clipboard
    wofi
  ];
}
