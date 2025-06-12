#!/usr/bin/env bash

set -euo pipefail

CODE_DIR="$HOME/Library/Application Support/Code/User"
NIX_CONFIG_DIR="$HOME/.nix-config/home/vscode"

mkdir -p "$CODE_DIR"

ln -sf "$NIX_CONFIG_DIR/settings.json" "$CODE_DIR/settings.json"
ln -sf "$NIX_CONFIG_DIR/keybindings.json" "$CODE_DIR/keybindings.json"
