{
  overlays,
  pkgs,
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
  };

  nixpkgs = {
    overlays = overlays;
    config.allowUnfree = true;
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
    showMenu = true;
    timeout = 5;
  };

  networking = {
    hostName = "w530";
    networkmanager.enable = true;
  };

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  systemd.defaultUnit = "multi-user.target";

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  users.users = {
    wes = {
      isNormalUser = true;
      extraGroups = [
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

  services = {
    resolved.enable = true; # systemd-resolved
    acpid.enable = true; # power button/lid signals handled sanely on laptops

    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PubkeyAuthentication = true;
        UseDns = false;
        UsePAM = true;
      };
    };

    iperf3 = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    btop
    curl
    ethtool
    eza
    fd
    jq
    lsof
    nmap
    pciutils
    ripgrep
    rsync
    strace
    unzip
    usbutils
    wget
    zip
  ];

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
        # plugins = [
        #   "git-open"
        #   "deno"
        # ];
        # custom = [
        #   "${config.home.homeDirectory}/.oh-my-zsh-custom" # FIXME
        # ];
      };
      shellAliases = {
        c = "clear";
        l = "eza -la";
        lt = "eza -laT -I=.git";
      };
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    tmux = {
      enable = true;
      keyMode = "vi";
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
          helper = "${pkgs.git-credential-manager}/bin/git-credential-manager"; # TODO: confirm this works
          "https://github.com/".useHttpPath = true;
        };
        push.autoSetupRemote = true;
      };
    };

    neovim = {
      enable = true;
      defaultEditor = true;

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
}
