{
  pkgs,
  lib,
  ...
}:

{
  programs.brave = {
    enable = true;

    package = pkgs.brave;

    extensions = [
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium
    ];

    commandLineArgs = [
      "--disable-component-update"
      "--disable-features=WebRtcAllowInputVolumeAdjustment"
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      # Linux-specific flags
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
    ];
  };
}
