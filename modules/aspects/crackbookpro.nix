{ den, overlays, inputs, ... }:
{
  den.aspects.crackbookpro = {
    darwin =
      { pkgs, ... }:
      {
        # Reuse existing darwin module
        imports = [
          ../../hosts/crackbookpro/darwin.nix
          inputs.mac-app-util.darwinModules.default
        ];

        # Pass overlays through to nix-darwin
        nixpkgs.overlays = overlays;
        nixpkgs.config.allowUnfree = true;
        nixpkgs.config.allowUnfreePredicate = _: true;
      };

    # Host contributes to user config if needed (none yet).
  };
}
