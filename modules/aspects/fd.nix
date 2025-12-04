{ den, ... }:
{
  den.aspects.fd = {
    homeManager = {
      programs.fd = {
        enable = true;
        hidden = true;
        ignores = [
          ".git/"
          "node_modules/"
        ];
      };
    };
  };
}
