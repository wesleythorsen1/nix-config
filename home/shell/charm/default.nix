{
  pkgs,
  ...
}:

{
  config = {
    home = {
      packages = with pkgs; [
        glow
        gum
        mods
      ];
    };
  };
}
