{ inputs, ... }:
let
  overlays = [
    inputs.nix-vscode-extensions.overlays.default
  ];
in
{
  _module.args.overlays = overlays;
}
