{
  inputs,
  ...
}:
let
  overlays = [
    inputs.nix-vscode-extensions.overlays.default
  ];
in
{
  # Make overlays available to other modules via _module.args.
  _module.args.overlays = overlays;
}
