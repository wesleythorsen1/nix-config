{ den, lib, pkgs, ... }:
{
  den.aspects.openai = {
    homeManager =
      { config, ... }:
      let
        cfg = config.openai;
      in
      {
        options.openai = {
          enable = lib.mkEnableOption "Configure OpenAI CLI and voice tools";

          apiKeyFile = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "Path to file containing OpenAI API key";
            example = "/run/secrets/openai-api-key";
          };
        };

        config = lib.mkIf cfg.enable {
          home.packages = with pkgs; [
            openai
          ];

          home.sessionVariables = lib.mkIf (cfg.apiKeyFile != null) {
            OPENAI_API_KEY = "$(cat ${cfg.apiKeyFile})";
          };
        };
      };
  };
}
