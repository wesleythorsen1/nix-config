{
  pkgs,
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
    ];
  };
}
