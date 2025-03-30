{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    ../../home
  ];
  
  home.username = "wesley";
  home.homeDirectory = "/Users/wesley";

  programs.git.userName  = "Wesley Thorsen";
  programs.git.userEmail = "wesley@kinetik.care";
  programs.git.extraConfig.credential.helper = "osxkeychain";
}
