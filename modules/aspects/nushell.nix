{ den, lib, ... }:
{
  den.aspects.nushell = {
    homeManager =
      { config, ... }:
      {
        home.shell.enableNushellIntegration = true;

        programs.nushell = {
          enable = true;
          shellAliases = {
            c = "clear";
          };
        };
      };

    # Cross-cutting: when eza is active, add aliases that depend on eza.
    den.aspects.nushell._.eza.homeManager =
      { config, ... }:
      lib.mkIf (config.programs.eza.enable or false) {
        programs.nushell.shellAliases = {
          l = "eza -la";
          lt = "eza_dynamic";
        };
      };

    # Cross-cutting: intelli-shell integration when feature is enabled.
    den.aspects.nushell._."intelli-shell".homeManager = {
      programs."intelli-shell".enableNushellIntegration = true;
    };

    # Cross-cutting: yazi integration when feature is enabled.
    den.aspects.nushell._.yazi.homeManager = {
      programs.yazi.enableNushellIntegration = true;
    };
  };
}
