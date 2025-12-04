{
  inputs,
  overlays,
  ...
}:
let
  inherit (inputs) home-manager mac-app-util;
in
{
  # Darwin host configuration for crackbookpro.
  flake.modules.darwin."hosts/crackbookpro" =
    { config, pkgs, lib, ... }:
    {
      imports = [
        # Existing host configuration
        ../../hosts/crackbookpro/darwin.nix

        # Extra modules wired in the old flake
        mac-app-util.darwinModules.default
        home-manager.darwinModules.home-manager
      ];

      # Pass overlays down to nix-darwin
      nixpkgs.overlays = overlays;

      # Enable unfree just like the legacy setup
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.allowUnfreePredicate = _: true;

      # Home Manager wiring (uses the homeManager module defined elsewhere)
      home-manager = {
        useGlobalPkgs = false;
        useUserPackages = true;
        users.wes = config.flake.modules.homeManager."users/wes";
        extraSpecialArgs = { inherit overlays inputs; };
        backupFileExtension = "backup";
        sharedModules = [ mac-app-util.homeManagerModules.default ];
      };
    };
}
