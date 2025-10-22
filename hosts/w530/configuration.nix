{
  overlays,
  pkgs,
  self,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "25.05";

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "wes"
    ];
  };

  nixpkgs = {
    overlays = overlays;
    config.allowUnfree = true;
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

  networking = {
    hostName = "w530";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  systemd = {
    defaultUnit = "multi-user.target";

    services.fetch-tailscale-key = {
      description = "Fetch Tailscale auth key from Mac (temporary bootstrap)";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      requiredBy = [ "tailscaled.service" ];
      before = [ "tailscaled.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "fetch-tailscale-key" ''
          set -euo pipefail
          install -d -m 700 /run/keys
          ${pkgs.curl}/bin/curl -fsS "http://crackbookpro.local/tailscale_key" \
            -o /run/keys/tailscale_key
          chmod 600 /run/keys/tailscale_key
        '';
      };
      wantedBy = [ "multi-user.target" ];
    };
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false; # FIXME: not safe
  };

  users.users = {
    wes = {
      isNormalUser = true;
      extraGroups = [
        # FIXME: move unnecessary perms to dev-shell
        "wheel"
        "docker"
        "kvm"
        "libvirtd"
        "networkmanager"
        "systemd-journal"
        "video"
      ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII2Mwvc/ia3Gtu0RQ6WmkoPVI1E+EKAd1akze0SJqA8c wes@crackbookpro"
      ];
    };
  };

  environment = {
    systemPackages = with pkgs; [
      curl
      jq
      unzip
      wget
    ];

    sessionVariables.ZDOTDIR = "/etc/zsh";
  };

  services = {
    resolved.enable = true; # systemd-resolved
    acpid.enable = true; # power button/lid signals handled sanely on laptops
    iperf3.enable = true;

    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PubkeyAuthentication = true;
        UseDns = false;
        UsePAM = true;
      };
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      publish.enable = true;
      publish.addresses = true;
      publish.domain = true;
    };

    tailscale = {
      enable = true;
      openFirewall = true;
      authKeyFile = "/run/keys/tailscale_key";
      useRoutingFeatures = "server";
      extraUpFlags = [
        "--ssh"
      ];
      extraSetFlags = [
        "--advertise-exit-node"
      ];
    };
  };

  programs = {
    tmux.enable = true;
    git.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    zsh = {
      enable = true;
      promptInit = "";
      interactiveShellInit = ''
        PROMPT='%n@%m:%~ %# '
        setopt NO_RCS
      '';
    };

    neovim = {
      enable = true;
      defaultEditor = true;
    };
  };

  specialisation.dev-shell.configuration = {
    security.sudo.extraRules = [
      # FIXME: not safe
      {
        users = [ "wes" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    environment = {
      systemPackages = with pkgs; [
        btop
        ethtool
        eza
        fd
        lsof
        nftables
        nmap
        pciutils
        ripgrep
        rsync
        strace
        usbutils
        zip
      ];

      # REVIEW: creates immutable copy of the source config (this repo)
      etc."nix-config".source = self.outPath;
    };

    programs = {
      bat.enable = true;
      iftop.enable = true;
      iotop.enable = true;
      mtr.enable = true;
      nexttrace.enable = true;

      zsh = {
        enable = true;
        enableBashCompletion = true;
        enableCompletion = true;
        enableGlobalCompInit = true;
        enableLsColors = true;
        autosuggestions = {
          enable = true;
          async = true;
        };
        syntaxHighlighting = {
          enable = true;
        };
        ohMyZsh = {
          enable = true;
          theme = "minimal";
          # TODO: setup to match home-manager
          # plugins = [
          #   "git-open"
          #   "deno"
          # ];
          # custom = [
          #   "${config.home.homeDirectory}/.oh-my-zsh-custom"
          # ];
        };
        shellAliases = {
          c = "clear";
          l = "eza -la";
          lt = "eza -laT -I=.git";
        };
      };

      git = {
        enable = true;
        prompt.enable = true;
        config = {
          user = {
            name = "wesleythorsen1";
            email = "wesley.thorsen@gmail.com";
            signingkey = "FAE484F021AE49E5";
          };
          alias = {
            co = "checkout";
            logl = "log --oneline --graph --all";
            pf = "push --force-with-lease";
          };
          core = {
            editor = "nvim";
            repositoryformatversion = 0;
            filemode = true;
            bare = false;
            logallrefupdates = true;
            ignorecase = false;
            precomposeunicode = true;
          };
          credential = {
            # TODO: confirm this works
            helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
            "https://github.com/".useHttpPath = true;
          };
          push = {
            autoSetupRemote = true;
          };
        };
      };

      neovim = {
        enable = true;
        configure = {
          customLuaRC = ''
            -- here your custom Lua configuration goes!

            vim.g.mapleader = " "

            vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
            vim.opt.number = true
            vim.opt.relativenumber = true

            vim.opt.clipboard = "unnamedplus"

            vim.opt.tabstop = 2
            vim.opt.softtabstop = 2
            vim.opt.shiftwidth = 2
            vim.opt.expandtab = false

            vim.opt.smartindent = true

            vim.opt.wrap = false

            vim.opt.swapfile = false
            vim.opt.backup = false
            vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
            vim.opt.undofile = true

            vim.opt.hlsearch = false
            vim.opt.incsearch = true

            vim.opt.termguicolors = true

            vim.opt.scrolloff = 8
            vim.opt.signcolumn = "yes"
            vim.opt.isfname:append("@-@")

            vim.opt.updatetime = 50

            vim.opt.colorcolumn = "80"
          '';
          packages.myVimPackage = with pkgs.vimPlugins; {
            # TODO: setup plugins to match home-manager
            # loaded on launch
            start = [ fugitive ];
            # manually loadable by calling `:packadd $plugin-name`
            opt = [ ];
          };
        };
      };

      yazi = {
        enable = true;
      };
    };
  };
}
