# Repository Guidelines

## Project Structure & Module Organization
- `flake.nix` pins nixpkgs/home-manager inputs, applies overlays for selected unstable packages, and exposes host outputs.
- `hosts/<host>/` contains machine definitions: macOS `darwin.nix` plus `etc/` assets, NixOS `configuration.nix` + `hardware-configuration.nix`, and per-host `home.nix` files that import shared Home Manager modules.
- `home/` holds modular Home Manager configs. `home/default.nix` aggregates common tooling (gh, nixfmt, yazi, etc.) and imports per-tool modules (`home/nvim`, `home/vscode`, `home/waybar`, `home/wezterm`, `home/accounts/email`, more), with supporting assets alongside each module.

## Build, Test, and Development Commands
- `nix flake check` — fast sanity check that flake inputs and modules evaluate.
- `darwin-rebuild switch --flake .#crackbookpro` — apply the macOS config (triggers Home Manager via nix-darwin module).
- `sudo nixos-rebuild switch --flake .#thinkpad` (or `.#w530`) — apply NixOS hosts; prefer `nixos-rebuild test` or `--dry-run` before switching.
- Home Manager is wired through host modules; if you need a standalone preview, target the appropriate user output (e.g., `home-manager switch --flake .#wes@thinkpad`) after defining it.

## Coding Style & Naming Conventions
- Nix files use 2-space indentation, aligned attribute sets, and trailing semicolons; format with `nixfmt` (provided via `nixfmt-rfc-style`).
- Keep module directories lowercase with hyphenless host names matching `hosts/<host>` outputs; place tool-specific config in `home/<tool>/default.nix` with any assets in the same folder.
- Scripts in `home/shell/bin` use short, kebab-case names; prefer POSIX sh where possible.

## Testing Guidelines
- Run `nix flake check` before pushing; add `--show-trace` if troubleshooting.
- For system changes, use `darwin-rebuild switch --dry-run --flake .#crackbookpro` or `nixos-rebuild test --flake .#thinkpad` to validate before applying.

## Commit & Pull Request Guidelines
- Follow conventional commits (`feat:`, `fix:`, `refactor:`) as seen in history; include the host or module touched when relevant.
- In PRs, summarize scope, note which hosts were rebuilt, and paste key command outputs (`nix flake check`, `*-rebuild --dry-run`). Mention any `flake.lock` updates or new unfree dependencies.
- Avoid committing secrets (SSH/GPG keys, tokens). Leverage platform keychains/agent settings already in `home/git` and host configs.

## AI Reference Materials
- Conversation transcripts and extracted plans for Codex/Claude live under `docs/ai/` (`conversations/` for raw/linearized chats, `plans/` for action plans).
- Before making structural changes (e.g., dendritic migration), review the relevant plan in `docs/ai/plans/` and source chat in `docs/ai/conversations/`.
