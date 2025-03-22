{ inputs, lib, config, pkgs, ... }:

let
  denoCompletions = pkgs.runCommand "deno-completions" {
    buildInputs = [ pkgs.deno ];
  } ''
    deno completions zsh > $out
  '';
in {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "wes";
    homeDirectory = "/home/wes";
    stateVersion = "24.11";
    
    shellAliases = {
      nhm = "home-manager";
    };

    sessionVariables = {
      EDITOR = "code";
    };

    packages = with pkgs; [
      awscli2
      btop
      deno
      docker
      doppler
      git
      gum
      neofetch
      jq
      # nodejs_16
      # nodejs_18
      nodejs_20
      # nodejs_22
      # powerline-fonts
      # terraform
      tree
      vim
      wget
      yank
      yazi
      zip
    ];

    file = {
      ".oh-my-zsh-custom/git-posh.zsh" = {
        source = pkgs.fetchurl {
          url = "https://gist.githubusercontent.com/wesleythorsen1/6d251331f8b0f6ede7ff32d38d7d4ba8/raw/3eea77779577c64e3a251754cae50e96a3e2841d/git-posh.zsh";
          sha256 = "sha256-77wsJUCO+55iwqqsfjBdX3htnscL9zz5YZClVwjVbxs=";
        };
      };

      ".oh-my-zsh-custom/plugins/git-open" = {
        source = pkgs.fetchFromGitHub {
          owner = "paulirish";
          repo = "git-open";
          rev = "2a66fcd7e3583bc934843bad4af430ac2ffcd859";
          sha256 = "sha256-t5ZmFHjIlmQc5F/4EkC6E9vvFVTF9xN2COgDXYR7V9o=";
        };
      };

      ".oh-my-zsh-custom/plugins/deno/_deno" = {
        source = denoCompletions;
      };
    };
  };

  programs = {
    home-manager = {
      enable = true;
    };

    git = {
      enable = true;
      userName  = "wes";
      userEmail = "wesley.thorsen@gmail.com";
      aliases = {
        co = "checkout";
        logl = "log --all --decorate --oneline --graph";
      };
      extraConfig = {
        push = { autoSetupRemote = true; };
        credential = {
          helper = "manager";
          "https://github.com".username = "wesleythorsen1";
          credentialStore = "cache";
        };
        # credential.helper = "${
        #     pkgs.git.override { withLibsecret = true; }
        #   }/bin/git-credential-libsecret";
      };
    };

    zsh = {
      enable = true;
      initExtra = ''
        # Nix
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
        # End Nix
      '';
      oh-my-zsh = {
        enable = true;
        custom = "$HOME/.oh-my-zsh-custom";
        # theme = "random";
        # theme = "minimal";
        theme = "xiong-chiamiov-plus";
        # theme = "funky";
        # theme = "agnoster"; # like oh-my-posh
        # theme = "amuse";
        # theme = "apple";
        plugins = [ "git-open" ];
      };
    };

    wezterm = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      #extraConfig = ''
      #  local wezterm = require("wezterm")
      #  config = wezterm.config_builder()
      #'';
    };

    starship = {
      enable = false;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    chromium = {
      enable = true;
      package = pkgs.brave;
      extensions = [
        { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
      ];
      commandLineArgs = [
        "--disable-features=WebRtcAllowInputVolumeAdjustment"
      ];
    };

    vscode = {
      enable = true;

    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
