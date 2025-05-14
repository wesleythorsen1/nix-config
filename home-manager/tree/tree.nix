{ config, pkgs, ... }:

{
  home = {
    shellAliases = {
      tree = "tree -a";
    };

    packages = with pkgs; [
      tree
    ];
  };
}
