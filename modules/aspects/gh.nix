{ den, lib, ... }:
{
  den.aspects.gh = {
    homeManager =
      { config, pkgs, ... }:
      let
        cfg = config.gh;
      in
      {
        imports = [
          ../../home/gh/gcd/default.nix
          ../../home/gh/ghq/default.nix
        ];

        options.gh = {
          enable = lib.mkEnableOption "Configure gh";

          extensions = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [ ];
            description = "List of gh extensions to install";
            example = [ pkgs.gh-eco ];
          };

          aliases = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = {
              prco = "pr checkout";
              prv = "pr view";
              prc = "pr create";
            };
            description = "Git aliases for gh";
          };

          settings = lib.mkOption {
            type = lib.types.attrs;
            default = {
              git_protocol = "https";
              editor = "code --wait";
              prompt = "enabled";
              prefer_editor_prompt = "disabled";
            };
            description = "Additional gh configuration settings";
          };

          ghq = {
            enable = lib.mkEnableOption "Configure ghq (repo management)" // { default = true; };
            root = lib.mkOption {
              type = lib.types.str;
              default = "${config.home.homeDirectory}/repos";
              description = "ghq root directory";
            };
            useEnvVar = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Set GHQ_ROOT environment variable";
            };
          };

          gcd = {
            enable = lib.mkEnableOption "ghq + fzf picker (gcd + Ctrl+g)" // { default = true; };
            key = lib.mkOption {
              type = lib.types.str;
              default = "^g";
              description = "Zsh keybinding for the gcd picker";
            };
            fzfOptions = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [
                "--height=50%"
                "--reverse"
                "--border"
              ];
              description = "Extra flags passed to fzf";
            };
            addCodeHelper = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Also add gcode (pick repo → open in VS Code)";
            };
          };
        };

        config = lib.mkIf cfg.enable {
          programs.gh = {
            enable = true;
            extensions = cfg.extensions;
            settings = lib.mkMerge [
              {
                git_protocol = "https";
                aliases = cfg.aliases;
                editor = cfg.settings.editor or "code --wait";
                prompt = cfg.settings.prompt or "enabled";
                prefer_editor_prompt = cfg.settings.prefer_editor_prompt or "disabled";
              }
              cfg.settings
            ];
          };

          programs.gh-dash = {
            enable = true;
            settings = {
              repoPaths = lib.mkIf cfg.ghq.enable [ cfg.ghq.root ];
            };
          };

          ghq = lib.mkIf cfg.ghq.enable {
            enable = true;
            root = cfg.ghq.root;
            useEnvVar = cfg.ghq.useEnvVar;
          };

          gcd = lib.mkIf cfg.gcd.enable {
            enable = true;
            key = cfg.gcd.key;
            fzfOptions = cfg.gcd.fzfOptions;
            addCodeHelper = cfg.gcd.addCodeHelper;
          };
        };
      };

    # Cross-cutting: prefer VS Code as editor when vscode aspect is active.
    den.aspects.gh._.vscode.homeManager = {
      programs.gh.settings.editor = "code --wait";
    };
  };
}
