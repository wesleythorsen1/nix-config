{ config, pkgs, ... }:

{
  home.username = "wes";
  home.homeDirectory = "/Users/wes";

  programs.git.userName  = "wesleythorsen1";
  programs.git.userEmail = "wesley.thorsen@gmail.com";
  programs.git.extraConfig.credential.helper = "osxkeychain";

  homeConfig.nixBuildTool  = "darwin-rebuild";
  homeConfig.nixConfigPath = "${config.home.homeDirectory}/nix-config";
  homeConfig.hostName  = "crackbookpro";

  imports = [
    ../../home
  ];
}
