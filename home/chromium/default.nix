{ config, pkgs, ... }:

{
  programs.chromium = {
    enable = true;

    package = pkgs.brave;

    extensions = [
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium
    ];
    
    commandLineArgs = [
      "--disable-component-update" # disables auto update check
      "--disable-features=WebRtcAllowInputVolumeAdjustment"
    ];
  };
}
