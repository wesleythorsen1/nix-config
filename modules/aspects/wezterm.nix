{ den, ... }:
{
  den.aspects.wezterm = {
    homeManager = {
      programs.wezterm = {
        enable = true;
        extraConfig = ''
          ${builtins.readFile ../../home/wezterm/config.lua}
        '';
      };
    };

    # Cross-cutting: shell integrations
    den.aspects.wezterm._.shell.homeManager = {
      programs.wezterm.enableBashIntegration = true;
      programs.wezterm.enableZshIntegration = true;
    };
  };
}
