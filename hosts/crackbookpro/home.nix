{
  config,
  pkgs,
  ...
}:

{
  home.username = "wes";
  home.homeDirectory = "/Users/wes";

  programs.git.userName = "wesleythorsen1";
  programs.git.userEmail = "wesley.thorsen@gmail.com";
  programs.git.extraConfig.credential.helper = "osxkeychain";

  imports = [
    ../../home
  ];
}
