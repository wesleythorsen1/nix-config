{ config, pkgs, ... }:

let
  scriptDir = ./bin;
  scripts = builtins.attrNames (builtins.readDir scriptDir);
in {
  programs.zsh = {
    enable = true;
    # initExtra = ''
    #  # Nix
    #  if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    #    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    #  fi
    #  # End Nix
    # '';
  };

  home.file = builtins.listToAttrs (map (name: {
    name = "bin/${name}";
    value = {
      source = "${scriptDir}/${name}";
      executable = true;
    };
  }) scripts);
}
