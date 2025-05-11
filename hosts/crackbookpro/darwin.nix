{
  pkgs,
  overlays,
  ...
}:

{
  nixpkgs.overlays = overlays;
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "crackbookpro";

  users.users.wes = {
    home  = "/Users/wes";
    shell = pkgs.zsh;
  };

  services.nix-daemon.enable = true; # Ensure the Nix daemon runs on startup

  system.stateVersion = 5;

  system.defaults = {
    NSGlobalDomain.AppleShowAllExtensions = true;  # Show file extensions
    dock.autohide                         = true;  # Auto-hide the Dock
    dock.mru-spaces                       = false; # Don’t “Automatically rearrange Spaces based on most recent use”
  };

  system.keyboard = {
    enableKeyMapping          = true;  # Turn on nix-darwin’s key-mapping support
    # swapLeftCommandAndLeftAlt = true;  # Swap the left Command (⌘) and left Option (⌥) keys
    # remapCapsLockToControl    = true;  # Remap Caps Lock to Control
    # swapLeftCtrlAndFn         = false; # Swap left Control and Fn/Globe
  };

  # services.launchd.userAgents."remap-command-control" = {
  #   enable = true;
  #   runAtLoad = true;
  #   serviceConfig = {
  #     Label            = "remap-command-control";
  #     Program          = "${pkgs.hidutil}/bin/hidutil";
  #     ProgramArguments = [
  #       "property" "--set" ''
  #         {
  #           "UserKeyMapping": [
  #             # 0x7000000E0 = Left Control; 0x7000000E3 = Left Command
  #             {"HIDKeyboardModifierMappingSrc":0x7000000E0,"HIDKeyboardModifierMappingDst":0x7000000E3},
  #             {"HIDKeyboardModifierMappingSrc":0x7000000E3,"HIDKeyboardModifierMappingDst":0x7000000E0}
  #           ]
  #         }
  #       ''
  #     ];
  #   };
  # };

  # environment.etc."tcc-pppc.mobileconfig" = {
  #   source = ./tcc-pppc.mobileconfig;
  #   mode   = "0644";
  # };

  # system.activationScripts.postUserActivation.text = ''
  #   profiles install -type configuration -path ${config.environment.etc."tcc-pppc.mobileconfig".source}
  # '';

  # Apply any changed defaults immediately (no login/logout)
  system.activationScripts.postUserActivation.text = ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.zsh.enable = true; # Enable zsh system-wide

  environment.systemPackages = with pkgs; [
    git
    coreutils
  ];
}
