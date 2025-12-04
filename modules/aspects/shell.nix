{ den, lib, ... }:
{
  den.aspects.shell = {
    homeManager =
      { config, pkgs, ... }:
      let
        inherit (pkgs) stdenv;
        activationCommand = if stdenv.isDarwin then "darwin-rebuild switch" else "home-manager switch";
        shellFunctions = builtins.listToAttrs (
          map (name: {
            name = name;
            value = builtins.readFile (../../home/shell/fns + "/${name}");
          }) (builtins.attrNames (builtins.readDir ../../home/shell/fns))
        );
      in
      {
        options.shell.functions = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          description = "Reusable shell functions available across modules";
        };

        config = {
          shell.functions = shellFunctions;

          home = {
            shell.enableShellIntegration = true;

            sessionVariables = {
              NIX_ACTIVE_CONFIG_DIR = "${config.home.homeDirectory}/nix";
            };

            sessionPath = [
              "${config.home.homeDirectory}/bin"
            ];

            shellAliases = {
              c = "clear";
              na = "nix-activate .";
            };

            file = {
              "nix" = {
                source = config.lib.file.mkOutOfStoreSymlink "${config.homeConfig.nixConfigPath}";
                recursive = true;
              };
              "bin/nix-activate" = {
                executable = true;
                text = ''
                  #!/usr/bin/env bash
                  flakePath="''${1:-''${NIX_ACTIVE_CONFIG_DIR:-"${config.home.homeDirectory}/nix"}}"

                  if [[ "$flakePath" != *"#"* ]]; then
                    hostname=$(hostname -s)
                    username="${config.home.username}"

                    if [[ -n "$username" && "$username" != "$(whoami)" ]]; then
                      flakePath="$flakePath#$username@$hostname"
                    else
                      flakePath="$flakePath#$hostname"
                    fi
                  fi

                  exec sudo ${activationCommand} --flake "$flakePath" --verbose
                '';
              };
            }
            // builtins.listToAttrs (
              map (name: {
                name = "bin/${name}";
                value = {
                  source = "${../../home/shell/bin}/${name}";
                  executable = true;
                };
              }) (builtins.attrNames (builtins.readDir ../../home/shell/bin))
            );
          };
        };
      };

    # Cross-cutting: set editor/alias when helix is present.
    den.aspects.shell._.helix.homeManager = {
      home.sessionVariables.EDITOR = lib.mkDefault "hx";
      home.shellAliases.v = lib.mkDefault "hx";
    };

    # Cross-cutting: set editor/alias when nvim is present (if helix not overriding).
    den.aspects.shell._.nvim.homeManager = {
      home.sessionVariables.EDITOR = lib.mkDefault "nvim";
      home.shellAliases.v = lib.mkDefault "nvim";
    };
  };
}
