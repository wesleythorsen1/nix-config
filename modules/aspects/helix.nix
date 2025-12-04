{ den, ... }:
{
  den.aspects.helix = {
    homeManager = {
      programs.helix = {
        enable = true;
        defaultEditor = true;
        settings.theme = "tokyonight";
      };
    };
  };
}
