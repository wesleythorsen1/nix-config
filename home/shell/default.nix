{
  config,
  pkgs,
  ...
}:

let
  inherit (pkgs) stdenv;
  
  activationCommand = if stdenv.isDarwin then "darwin-rebuild switch" else "home-manager switch";
in {
  home = {
    shell.enableShellIntegration = true;

    sessionVariables = {
      EDITOR = "code";
      NIX_ACTIVE_CONFIG_DIR = "${config.home.homeDirectory}/.nix-config";
    };

    sessionPath = [
      "${config.home.homeDirectory}/bin"
    ];

    shellAliases = {
      c = "clear";
      l = "eza -la";
      lt = "eza -laT -I=.git";
      v = "nvim";
      na = "nix-activate"; # see "bin/nix-activate" script below
    };

    file = {
      ".nix-config" = {
        # symlink "~/.nix-config" to physical repo location
        source = config.lib.file.mkOutOfStoreSymlink "${config.homeConfig.nixConfigPath}";
        recursive = true;
      };
      "bin/nix-activate" = {
        # usage:
        #   `nix-activate`                            - defaults to $NIX_ACTIVE_CONFIG_DIR if set, otherwise "~/.nix-config"
        #   `nix-activate ./nix/config/dir#host@user` - with path (hostname and username optional, default to current)
        executable = true;
        text = ''
          #!/usr/bin/env bash
          flakePath="''${1:-''${NIX_ACTIVE_CONFIG_DIR:-"${config.home.homeDirectory}/.nix-config"}}"
          exec sudo ${activationCommand} --flake "$flakePath"
        '';
      };
    } // builtins.listToAttrs (map (name: {
      name = "bin/${name}";
      value = {
        source = "${./bin}/${name}";
        executable = true;
      };
    }) (builtins.attrNames (builtins.readDir ./bin)));

  };
}
