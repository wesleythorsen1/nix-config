{ den, ... }:
{
  den.aspects."fabric-ai" = {
    homeManager = {
      programs.fabric-ai = {
        enable = true;
        enablePatternsAliases = true;
        enableYtAlias = false;
      };
      home.sessionVariables.FABRIC_ALIAS_PREFIX = "fab-";
    };

    # Cross-cutting: enable shell integrations when bash/zsh are present.
    den.aspects."fabric-ai"._.shell.homeManager = {
      programs.fabric-ai.enableBashIntegration = true;
      programs.fabric-ai.enableZshIntegration = true;
    };
  };
}
