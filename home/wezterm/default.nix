{ config, pkgs, ... }:

{
  programs.wezterm = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    extraConfig = ''
      ${builtins.readFile ./config.lua}
    '';
  };
}
