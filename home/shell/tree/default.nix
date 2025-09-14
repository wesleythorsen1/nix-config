{ config, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      tree
    ];

    shellAliases.tree = "tree -a";
  };
}
