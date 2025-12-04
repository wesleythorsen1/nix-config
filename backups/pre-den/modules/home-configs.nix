{
  inputs,
  overlays,
  config,
  ...
}:
{
  flake.homeConfigurations."wes@crackbookpro" =
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = "aarch64-darwin";
        overlays = overlays;
        config.allowUnfree = true;
        config.allowUnfreePredicate = _: true;
      };
      modules = [
        config.flake.modules.homeManager."users/wes"
      ];
      extraSpecialArgs = {
        inherit overlays inputs;
      };
    };
}
