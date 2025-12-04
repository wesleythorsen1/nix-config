{ den, pkgs, ... }:
{
  den.aspects."open-faas" = {
    homeManager = {
      home = {
        packages = with pkgs; [ faas-cli ];
        shellAliases.faas = "faas-cli";
      };
    };
  };
}
