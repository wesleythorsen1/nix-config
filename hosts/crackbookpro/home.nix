{
  ...
}:

{
  home.username = "wes";
  home.homeDirectory = "/Users/wes";

  programs.git.settings = {
    user = {
      name = "wesleythorsen";
      email = "wesley.thorsen@gmail.com";
    };
    credential.helper = "osxkeychain";
  };

  imports = [
    ../../home
  ];
}
