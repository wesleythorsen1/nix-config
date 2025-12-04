{ den, lib, pkgs, ... }:
{
  den.aspects.charm = {
    homeManager =
      { config, ... }:
      {
        home.packages = with pkgs; [
          glow
          gum
          mods
        ];

        home.activation.linkCharmModsSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          #!/usr/bin/env bash
          set -euo pipefail
          MODS_DIR="${config.home.homeDirectory}/Library/Application Support/mods"
          NIX_CONFIG_DIR="${config.homeConfig.nixConfigPath}/home/charm"
          mkdir -p "$MODS_DIR"
          ln -sf "$NIX_CONFIG_DIR/mods.yml" "$MODS_DIR/mods.yml"
        '';
      };
  };
}
