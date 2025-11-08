# Git submodules

This directory is for externally linked git repos. Currently linking github:wesleythorsen1/nix-modules so that I have a mutable copy of ./modules/home/vscode/settings.json and modules/home/vscode/keybindings.json, and to allow a tighter feedback loop when making and testing changes in nix-modules. 

## Useful commands

```bash
git submodule add https://github.com/wesleythorsen1/nix-modules external/nix-modules
# optional: track a branch
git submodule set-branch -b main external/nix-modules

cd external/nix-modules

# if only tracking a single file
git sparse-checkout init --cone
git sparse-checkout set path/to/vscode/settings.json

# pull it down if needed
git fetch --depth=1 origin main
git checkout main
```
