{ }:
{
  # Shell feature extracted from home/shell/default.nix
  flake.modules.homeManager."features/shell" = import ../../home/shell/default.nix;
}
