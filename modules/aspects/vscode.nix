{ den, lib, pkgs, inputs, overlays, ... }:
{
  den.aspects.vscode = {
    homeManager =
      { config, ... }:
      let
        overlayedPkgs = pkgs; # overlays already applied via nixpkgs.overlays upstream
      in
      {
        home.activation.linkVSCodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          #!/usr/bin/env bash
          set -euo pipefail
          CODE_DIR="${config.home.homeDirectory}/Library/Application Support/Code/User"
          NIX_CONFIG_DIR="${config.homeConfig.nixConfigPath}/home/vscode"
          mkdir -p "$CODE_DIR"
          ln -sf "$NIX_CONFIG_DIR/settings.json" "$CODE_DIR/settings.json"
          ln -sf "$NIX_CONFIG_DIR/keybindings.json" "$CODE_DIR/keybindings.json"
        '';

        programs.vscode = {
          enable = true;

          profiles.default = {
            enableExtensionUpdateCheck = true;
            enableUpdateCheck = true;
            extensions = with overlayedPkgs.vscode-marketplace; [
              alefragnani.bookmarks
              amih90.to
              bbenoist.nix
              dbaeumer.vscode-eslint
              denoland.vscode-deno
              esbenp.prettier-vscode
              gruntfuggly.todo-tree
              heaths.vscode-guid
              jnoortheen.nix-ide
              johnpapa.winteriscoming
              jsynowiec.vscode-insertdatestring
              mohsen1.prettify-json
              naumovs.color-highlight
              orta.vscode-jest
              oven.bun-vscode
              redhat.vscode-yaml
              rvest.vs-code-prettier-eslint
              shd101wyy.markdown-preview-enhanced
              streetsidesoftware.code-spell-checker
              visualstudioexptteam.intellicode-api-usage-examples
              visualstudioexptteam.vscodeintellicode
            ];
          };
        };
      };
  };
}
