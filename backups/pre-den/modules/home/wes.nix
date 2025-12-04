{
  overlays,
  inputs,
  config,
  ...
}:
{
  # Home Manager module for the wes user.
  flake.modules.homeManager."users/wes" =
    { pkgs, ... }:
    {
      imports = [
        # Existing HM entry point that pulls in ./home/default.nix
        ../../../hosts/crackbookpro/home.nix
        config.flake.modules.homeManager."features/git"
        config.flake.modules.homeManager."features/shell"
        config.flake.modules.homeManager."features/tree"
      ];

      nixpkgs = {
        overlays = overlays;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
      };
    };
}
