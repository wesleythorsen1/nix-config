{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    ../../home
  ];
  
  home.username = "wthorsen";
  home.homeDirectory = "/Users/wthorsen";

  programs.git.userName  = "Wesley Thorsen";
  programs.git.userEmail = "wesley@kinetik.care";
  programs.git.extraConfig.credential.helper = "osxkeychain";
}
