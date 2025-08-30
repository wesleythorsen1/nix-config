# Claude Code Context for Nix Config

## Project Overview
Personal Nix configuration repository managing both Darwin (macOS) and NixOS systems using flakes and Home Manager.

## Architecture
- **Hosts**: `crackbookpro` (aarch64-darwin), `thinkpad` (x86_64-linux)
- **Package Management**: Nix flakes with overlays for unstable packages
- **Home Management**: Home Manager for user-level configurations
- **Structure**: Modular design with per-program configurations in `home/`

## Common Commands
```bash
# Rebuild and switch any platform (alias for `sudo {this-platforms-nix-build-tool} switch --flake ${flake-path-from-input}`)
nix-activate .
nix-activate .#crackbookpro

# shortcut for nix-activate
na .

# Rebuild Darwin system (macOS)
darwin-rebuild switch --flake .

# Rebuild NixOS system
sudo nixos-rebuild switch --flake .

# Update home-manager only
home-manager switch --flake .

# Check flake for issues
nix flake check

# Update flake inputs
nix flake update
```

## Key Patterns
- Each program has its own module in `home/*/default.nix`
- Overlays used to pull specific packages from unstable or pinned commits
- Host-specific configs in `hosts/*/`
- Dotfiles managed via Home Manager, not symlinks
- ZSH uses oh-my-zsh with custom ZSH-compatible posh-git prompt

## Known Issues & Solutions
- nodejs_16 requires permittedInsecurePackages due to CVE
- Some packages pulled from unstable for latest features
- VSCode extensions managed via nix-vscode-extensions flake

## Recent Changes
- Switched from neofetch to fastfetch
- Updated VSCode settings for claude-code integration
- Added ghq/gcd/gcode commands for repo management
- Added claude-code to development tools

## Dependencies
- nixpkgs stable (25.05) and unstable channels
- home-manager, nix-darwin, hyprland flakes
- nix-vscode-extensions for VSCode extension management

# Project Context

## Repository Structure
```
nix-config/
├── flake.nix           # Main flake configuration
├── hosts/              # Host-specific configurations
│   ├── crackbookpro/   # aarch64-darwin (macOS)
│   └── thinkpad/       # x86_64-linux (NixOS)
├── home/               # Home Manager modules
│   ├── vscode/         # VSCode config with claude-code setup
│   ├── zsh/            # Shell configuration
│   ├── nvim/           # Neovim setup with LSP
│   ├── git/            # Git configuration
│   └── */              # Other program modules
└── bin/                # Custom scripts
```

## System Details
- **Primary Host**: crackbookpro (M1 MacBook Pro)
- **Secondary Host**: thinkpad (x86_64 Linux)
- **User**: wes
- **Nix Channels**: stable 25.05, unstable, pinned a71323f
- **Home Manager**: Integrated via flake

## Development Environment
- **Editor**: VSCode with claude-code integration
- **Shell**: Zsh with starship prompt
- **Terminal**: WezTerm
- **Package Manager**: ghq for repo management
- **Runtime**: Node.js 20 (unstable), Node.js 16 (legacy/insecure)

## Key Configuration Files
- `home/vscode/settings.json` - VSCode settings including claude-code
- `home/zsh/default.nix` - Shell setup with custom commands (gcd, gcode)
- `home/git/default.nix` - Git configuration with signing keys
- `hosts/*/home.nix` - Host-specific Home Manager imports

*Auto-updated by Claude Code - Last modified: 2025-08-26*