{
  pkgs,
  overlays,
  ...
}:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # TODO: these two lines conflict with `home-manager.useGlobalPkgs = true;`.
  # useGlobalPkgs tell home-manager to use the global config (overlays, allowUnfree, etc.).
  # need to figure out how to properly inject the relevant nixpkgs config and use it here,
  # so that I can remove useGlobalPkgs.
  nixpkgs.overlays = overlays;
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "crackbookpro";

  system = {
    stateVersion = 5;

    primaryUser = "wes";

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions    = true;  # Show file extensions
      };

      dock = {
        autohide                  = true;  # Auto-hide the Dock
        mru-spaces                = false; # Don’t “Automatically rearrange Spaces based on most recent use”
      };

      WindowManager = {
        GloballyEnabled           = true;  # Enable "Stage Manager"
      };
    };

    keyboard = {
      enableKeyMapping            = true;  # Turn on nix-darwin’s key-mapping support
      # swapLeftCommandAndLeftAlt = true;  # Swap the left Command (⌘) and left Option (⌥) keys
      # remapCapsLockToControl    = true;  # Remap Caps Lock to Control
      # swapLeftCtrlAndFn         = false; # Swap left Control and Fn/Globe
    };

    # activationScripts = {
    #   # Apply any changed defaults immediately (no login/logout)
    #   postUserActivation.text = ''
    #     /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    #   '';

    #   # podmanMachineInit = {
    #   #   deps = [ pkgs.podman pkgs.grep ];
    #   #   text = ''
    #   #     # if no default machine exists yet, create it
    #   #     if ! podman machine list --format "{{.Name}}" \
    #   #       | grep -q "^default$"; then
    #   #       podman machine init
    #   #     fi
    #   #   '';
    #   # };

    #   # postUserActivation.text = ''
    #   #   profiles install -type configuration -path ${config.environment.etc."tcc-pppc.mobileconfig".source}
    #   # '';
    # };
  };

  users.users = {
    wes = {
      home  = "/Users/wes";
      shell = pkgs.zsh;
    };
  };

  # launchd.user.agents.podman-machine-start = {
  #   command = "${pkgs.podman}/bin/podman machine start";
  #   serviceConfig = {
  #     RunAtLoad = true;
  #     KeepAlive = true;
  #   };
  # };

  services = {
    # nix-daemon.enable             = true; # Ensure the Nix daemon runs on startup

    # launchd = {
    #   userAgents."remap-command-control" = {
    #     enable = true;
    #     runAtLoad = true;
    #     serviceConfig = {
    #       Label            = "remap-command-control";
    #       Program          = "${pkgs.hidutil}/bin/hidutil";
    #       ProgramArguments = [
    #         "property" "--set" ''
    #           {
    #             "UserKeyMapping": [
    #               # 0x7000000E0 = Left Control; 0x7000000E3 = Left Command
    #               {"HIDKeyboardModifierMappingSrc":0x7000000E0,"HIDKeyboardModifierMappingDst":0x7000000E3},
    #               {"HIDKeyboardModifierMappingSrc":0x7000000E3,"HIDKeyboardModifierMappingDst":0x7000000E0}
    #             ]
    #           }
    #         ''
    #       ];
    #     };
    #   };
    # };
  };

  environment = {
    # etc = {
    #   "tcc-pppc.mobileconfig" = {
    #     source = ./tcc-pppc.mobileconfig;
    #     mode   = "0644";
    #   };
    # };

    systemPackages = with pkgs; [
      git
      coreutils
    ];
  };

  programs.zsh.enable = true; # Enable zsh system-wide
}
