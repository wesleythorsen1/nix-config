This project is for Nix, NixOS, home-manager, and nix-darwin related questions. I am using Nix to manager my computers. I currently have a 2021 M1 MacBook Pro running MacOS fully managed by nix-darwin with home-manager (named "crackbookpro"), and an x86 ThinkPad laptop running NixOS (named "bbetty") that also using home-manager.

The correct way to escape nix string interpolation is with two single quotes ("''") right before the dollar sign, like:
```
example = "example string ''${the dollar sign is escaped, this is not interpolated}";
```

My nix-config repo's directory structure:
```
.
├── bin
│   ├── clean
│   └── update
├── flake.lock
├── flake.nix
├── home
│   ├── accounts
│   │   └── email
│   │       ├── default.nix
│   │       ├── personal
│   │       │   └── default.nix
│   │       └── take2
│   │           └── default.nix
│   ├── chromium
│   │   ├── default.nix
│   │   ├── vimium-backup.css
│   │   └── vimium.css
│   ├── default.nix
│   ├── dotnet
│   │   └── default.nix
│   ├── fd
│   │   └── default.nix
│   ├── fzf
│   │   └── default.nix
│   ├── git
│   │   └── default.nix
│   ├── hyprland
│   │   ├── default.nix
│   │   ├── hyprctl-workspace-backward.sh
│   │   └── hyprctl-workspace-forward.sh
│   ├── nodejs
│   │   └── default.nix
│   ├── nvim
│   │   ├── .nvimrc
│   │   ├── default.nix
│   │   ├── lsp.lua
│   │   ├── my-config
│   │   │   ├── init.lua
│   │   │   ├── remap.lua
│   │   │   └── set.lua
│   │   └── telescope.lua
│   ├── podman
│   │   └── default.nix
│   ├── python3
│   │   └── default.nix
│   ├── shell
│   │   ├── bin
│   │   │   ├── git-archive
│   │   │   ├── git-cp
│   │   │   ├── git-mv
│   │   │   └── stay-awake
│   │   └── default.nix
│   ├── starship
│   │   ├── config.toml
│   │   └── default.nix
│   ├── thunderbird
│   │   └── default.nix
│   ├── tree
│   │   └── default.nix
│   ├── vscode
│   │   ├── default.nix
│   │   ├── keybindings.json
│   │   ├── link-vscode-config.sh
│   │   └── settings.json
│   ├── waybar
│   │   ├── config.json
│   │   ├── default.nix
│   │   └── style.css
│   ├── wezterm
│   │   ├── config.lua
│   │   └── default.nix
│   └── zsh
│       └── default.nix
└── hosts
    ├── crackbookpro
    │   ├── darwin.nix
    │   ├── etc
    │   │   └── tcc-pppc.mobileconfig
    │   └── home.nix
    └── thinkpad
        ├── configuration.nix
        ├── hardware-configuration.nix
        ├── home.nix
        └── nvidia.nix
```
