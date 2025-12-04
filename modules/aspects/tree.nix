{ den, pkgs, ... }:
{
  den.aspects.tree = {
    homeManager = {
      home.packages = [ pkgs.tree ];
    };

    # Cross-cutting: add shell aliases when zsh is present.
    den.aspects.tree._.zsh.homeManager = {
      programs.zsh.shellAliases = {
        t = "tree -C";
        tt = "tree -C -L 2";
      };
    };
  };
}
