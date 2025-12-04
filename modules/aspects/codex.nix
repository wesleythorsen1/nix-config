{ den, pkgs, ... }:
{
  den.aspects.codex = {
    homeManager = {
      home.packages = with pkgs; [ codex ];
    };
  };
}
