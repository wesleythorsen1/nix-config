{
  pkgs,
  overlays,
  ...
}:

{
  imports = [
    ../../modules/darwin-tcc-permissions.nix
    ../../modules/mac-app-wrappers.nix
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.overlays = overlays;
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  networking.hostName = "crackbookpro";

  system = {
    stateVersion = 5;

    primaryUser = "wes";

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true; # Show file extensions
        AppleShowAllFiles = true; # Show hidden folders in finder
        InitialKeyRepeat = 15; # default 25
        KeyRepeat = 2;
      };

      dock = {
        autohide = true; # Auto-hide the Dock
        mru-spaces = false; # Don’t “Automatically rearrange Spaces based on most recent use”
      };

      WindowManager = {
        GloballyEnabled = true; # Enable "Stage Manager"
      };
    };

    keyboard = {
      enableKeyMapping = true; # Turn on nix-darwin's key-mapping support
      # swapLeftCommandAndLeftAlt = true;  # Swap the left Command (⌘) and left Option (⌥) keys
      # remapCapsLockToControl    = true;  # Remap Caps Lock to Control
      # swapLeftCtrlAndFn         = false; # Swap left Control and Fn/Globe
    };

    activationScripts = {
      # Apply any changed defaults immediately (no login/logout)
      postActivation.text = ''
        /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
        
        # Install TCC profile
        if [ -f "${./etc/tcc-pppc.mobileconfig}" ]; then
          echo "Installing TCC configuration profile..."
          profiles remove -identifier "com.yourorg.tcc-pppc" 2>/dev/null || true
          profiles install -type configuration -path "${./etc/tcc-pppc.mobileconfig}"
        fi
      '';
    };
  };
  
  # Enable TCC permission management
  services.tccPermissions = {
    enable = true;
    autoBackup = true;
    autoRestore = true;
    applications = [ "brave" "slack" "zoom" "vscode" ];
  };
  
  # Enable stable app wrappers
  services.macAppWrappers = {
    enable = true;
    applications = [ "brave" "slack" "zoom" "vscode" ];
  };

  users.users = {
    wes = {
      home = "/Users/wes";
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
    etc = {
      "tcc-pppc.mobileconfig" = {
        source = ./etc/tcc-pppc.mobileconfig;
      };
    };

    systemPackages = with pkgs; [
      git
      coreutils
    ];
  };

  programs.zsh.enable = true; # Enable zsh system-wide
}
