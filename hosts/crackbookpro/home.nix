{
  ...
}:

{
  home.username = "wes";
  home.homeDirectory = "/Users/wes";

  programs.git.settings = {
    user = {
      name = "wesleythorsen1";
      email = "wesley.thorsen@gmail.com";
    };
    credential.helper = "osxkeychain";
  };

  imports = [
    ../../home
  ];
}
