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
    ./fzf/fzf.nix
    ./nvim/nvim.nix
    ./starship/starship.nix
    ./tree/tree.nix
    ./wayland/wayland.nix
    ./wezterm/wezterm.nix
    ./zsh/zsh.nix
  ];

  nixpkgs = {
    overlays = [
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "wes";
    homeDirectory = "/home/wes";
    stateVersion = "24.11";
    
    shellAliases = let
      flakeDir = "~/nix";
    in {
      v = "nvim";

      hm = "home-manager";
      hms = "home-manager switch --flake ${flakeDir}";
    };

    sessionVariables = {
      EDITOR = "nvim";
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
      pipes-rs
      qutebrowser
      ripgrep
      rsclock
      # terraform
      # tree
      #vim
      vlc
      wget
      wl-clipboard
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

          helper = "${
              pkgs.git.override { withLibsecret = true; }
            }/bin/git-credential-libsecret";
          # helper = "libsecret";
          # "https://github.com".username = "wesleythorsen1";
          # credentialStore = "cache";
        };
        # credential.
      };
    };

    chromium = {
      enable = true;
      package = pkgs.brave;
      extensions = [
        { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
        { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium
      ];
      commandLineArgs = [
        "--disable-features=WebRtcAllowInputVolumeAdjustment"
      ];
    };

    vscode = {
      enable = true;
    };

    kitty.enable = true; # required for the default Hyprland config
    
    fd = {
      enable = true;
      hidden = true;
      ignores = [
        ".git/"
	"node_modules/"
      ];
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
