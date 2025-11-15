{
  lib,
  pkgs,
  overlays,
  ...
}:

{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "wes"
      ];
    };
    nixPath = lib.mkForce [ ]; # not needed for flake

    # linux-builder = {
    #   enable = true;
    #   ephemeral = true;
    #   protocol = "ssh";
    #   systems = [
    #     "aarch64-linux"
    #     "x86_64-linux"
    #   ];
    #   maxJobs = 4;
    #   config = {
    #     boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
    #     nix.settings.extra-platforms = [ "x86_64-linux" ];

    #     virtualisation = {
    #       darwin-builder = {
    #         diskSize = 40 * 1024;
    #         memorySize = 8 * 1024;
    #       };
    #       cores = 6;
    #     };
    #   };
    # };
  };
  nixpkgs.config.checkByDefault = false;
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
        orientation = "right";
        mru-spaces = false; # Don’t “Automatically rearrange Spaces based on most recent use”
      };

      WindowManager = {
        GloballyEnabled = true; # Enable "Stage Manager"
      };
    };

    keyboard = {
      enableKeyMapping = true; # Turn on nix-darwin’s key-mapping support
      # swapLeftCommandAndLeftAlt = true;  # Swap the left Command (⌘) and left Option (⌥) keys
      # remapCapsLockToControl    = true;  # Remap Caps Lock to Control
      # swapLeftCtrlAndFn         = false; # Swap left Control and Fn/Globe
    };
  };

  users.users = {
    wes = {
      home = "/Users/wes";
      shell = pkgs.zsh;
    };
  };

  services = {
    tailscale = {
      enable = true;
    };
  };

  environment = {
    shells = [ pkgs.zsh ];

    systemPackages = with pkgs; [
      coreutils
      curl
      exiftool
      fastfetch
      git
      jq
      nixos-rebuild # for building NixOS configs
      unzip
      wget
    ];
  };

  programs = {
    zsh = {
      enable = true;
      promptInit = ''
        setopt prompt_subst
        . ${./etc/posh-git.zsh}
        PROMPT='%n@%m %1~$(git_prompt_info) » '
      '';
      interactiveShellInit = ''
        autoload -U up-line-or-beginning-search
        autoload -U down-line-or-beginning-search
        zle -N up-line-or-beginning-search
        zle -N down-line-or-beginning-search
        bindkey "^[[A" up-line-or-beginning-search
        bindkey "^[[B" down-line-or-beginning-search

        show_fastfetch () {
          # Only for interactive shells
          case "$-" in
            *i*) : ;;     # interactive
            *)   return ;; # non-interactive login (e.g., ssh with a command)
          esac

          # Require a real terminal and skip "dumb"
          [ -t 1 ] || return
          [ "''${"TERM:-"}" = "dumb" ] && return

          # Run fastfetch if present
          if command -v fastfetch >/dev/null 2>&1; then
            fastfetch
          fi
        }

        show_fastfetch
      '';
      enableAutosuggestions = true;
      enableBashCompletion = true;
      enableCompletion = true;
      enableFzfCompletion = true;
      enableFzfGit = true;
      enableFzfHistory = true;
      enableSyntaxHighlighting = true;
    };

    bash = {
      enable = true;
      interactiveShellInit = ''
        case "$-" in *i*) ;; *) return ;; esac
        . ${./etc/posh-git.zsh}
        __posh_prompt_prefix="\u@\h \W "
        __posh_prompt_suffix=" » "
        PROMPT_COMMAND='__posh_git_ps1 "$__posh_prompt_prefix" "$__posh_prompt_suffix"'

        bind '"\e[A": history-search-backward'
        bind '"\e[B": history-search-forward'
      '';
    };

    tmux = {
      enable = true;
      enableFzf = true;
      enableMouse = true;
      enableSensible = true;
      enableVim = true;
    };
  };
}
