{ }:
{
  # Git/Home Manager feature extracted from home/git/default.nix
  flake.modules.homeManager."features/git" = import ../../home/git/default.nix;
}
