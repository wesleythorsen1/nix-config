{ den, pkgs, ... }:
{
  den.aspects.nodejs = {
    homeManager = {
      home = {
        packages = with pkgs; [
          nodejs_24
        ];
        shellAliases = {
          serverless = "npx serverless@3";
          sls = "serverless";
          opencommit = "npx opencommit";
          oco = "opencommit";
        };
      };
    };
  };
}
