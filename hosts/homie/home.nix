{ config, pkgs, ... }:

{
  home.username = "wthorsen";
  home.homeDirectory = "/Users/wthorsen";

  programs.git.userName  = "Wesley Thorsen";
  programs.git.userEmail = "wesley@kinetik.care";
  programs.git.extraConfig.credential.helper = "osxkeychain";

  homeConfig.nixBuildTool  = "home-manager";
  homeConfig.nixConfigPath = "${config.home.homeDirectory}/.config/nix-config";
  homeConfig.hostName  = "homie";

  imports = [
    ../../home
  ];

  home.packages = with pkgs; [
    unstable.slack
  ];
}
