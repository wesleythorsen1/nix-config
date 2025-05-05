{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    ../../home
  ];
  
  home.username = "wes";
  home.homeDirectory = "/Users/wes";
  home.shellAliases.switch = "darwin-rebuild switch --flake ~/.config/nix-config#crackbookpro";

  programs.git.userName  = "wesleythorsen1";
  programs.git.userEmail = "wesley.thorsen@gmail.com";
  programs.git.extraConfig.credential.helper = "osxkeychain";

  home.packages = with pkgs; [
    unstable.slack
  ];
}
