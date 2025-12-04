{
  inputs,
  overlays,
  config,
  ...
}:
{
  flake.darwinConfigurations.crackbookpro =
    inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {
        inherit overlays inputs;
      };
      modules = [
        config.flake.modules.darwin."hosts/crackbookpro"
      ];
    };
}
