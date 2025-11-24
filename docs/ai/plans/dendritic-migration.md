# Dendritic/den migration plan (from dendritic conversation)

Context: Conversation `docs/ai/conversations/dendritic_conversation.md` outlines moving this repo to the dendritic pattern using the `vic/den` template. This plan distills the agreed steps.

## Template posture
- Keep the generated `flake.nix` and `modules/dendritic.nix` from `nix flake init -t github:vic/den`; all work happens inside `modules/`.
- `modules/inputs.nix` holds core inputs (nixpkgs, HM, darwin, den, etc.). Add feature-specific inputs near their aspects if needed; flake-file will merge them.
- `modules/namespace.nix` creates namespaces; keep `eg` for reference initially, add a personal namespace (e.g. `wes`) when splitting aspects.

## Host/home registry
- Update `modules/den.nix` to register real targets:
  - `den.hosts.aarch64-darwin.crackbookpro.users.wes = { };`
  - Add other hosts later (e.g. `den.hosts.x86_64-linux.bbetty.users.wes = { };`).
  - `den.homes.aarch64-darwin.wes = { };` for standalone HM output.

## Aspects to create/adapt
1) Clone/rename template aspects:
   - `modules/aspects/alice.nix` → `modules/aspects/wes.nix`.
   - `modules/aspects/igloo.nix` → `modules/aspects/crackbookpro.nix` (darwin host instead of NixOS demo).
2) Host aspect (`crackbookpro`):
   - Under `den.aspects.crackbookpro.darwin`, move content from `hosts/crackbookpro/darwin.nix` (nix settings, overlays, packages, services, shell defaults, etc.).
   - Add host-level HM defaults if any shared user tweaks are needed.
3) User aspect (`wes`):
   - Under `den.aspects.wes.homeManager`, move content from `hosts/crackbookpro/home.nix` and `home/default.nix` (username/homeDirectory, git identity, global HM options).
   - Include `den._.primary-user` plus your CLI feature aspects once they exist.
4) Feature aspects (split out once base works; can start inline in `wes.nix`):
   - Shell: move `home/shell/default.nix` settings.
   - Git tooling: move `home/git/default.nix` (aliases/config; identity stays in `wes`).
   - Tree: move `home/tree/default.nix` (package + aliases).
   - Optional: add more aspects as you peel features from existing host/home files; consider placing them under a personal namespace (e.g. `modules/aspects/wes/cli-shell.nix`, etc.).

## Defaults and routing
- In `modules/aspects/defaults.nix`, set state versions to match your real targets (e.g., darwin stateVersion, nixos/home stateVersion). Keep the routing/parametric wiring (`den.default.includes`, `eg.routes`) unless you have a reason to change it.
- `eg/routes.nix` demonstrates routing; reuse as-is initially. Adjust only if you need different user↔host wiring.

## Example/VM material
- The `modules/aspects/eg/*` VM/xfce/autologin examples and `modules/vm.nix` are demo-only. Leave them untouched as reference or remove them once comfortable; they are not required for crackbookpro + wes.

## Incremental workflow
1) Update `modules/den.nix` with crackbookpro + wes.
2) Create `modules/aspects/wes.nix` and `modules/aspects/crackbookpro.nix` with minimal ported settings (identity, stateVersion, base darwin options). Run `nix flake check`.
3) Gradually move features from `home/*` into the `wes` aspect (or split aspects) and from `hosts/crackbookpro/darwin.nix` into the `crackbookpro` aspect. After each move, run `nix flake check` and `darwin-rebuild switch --flake .#crackbookpro --dry-run`.
4) Once stable, refactor features into dedicated aspects under a personal namespace and update `wes` includes accordingly.
5) Add additional hosts (e.g., NixOS laptop) by cloning the host aspect pattern and updating `den.hosts.*`.

## Commands to validate
- `nix flake check`
- `darwin-rebuild switch --dry-run --flake .#crackbookpro`

## Forbidden Commands
**Do not** run any commands that will apply or activate this nix configuration on this host machine or user (or any host machine or user). You can use any command with the `--dry-run` flag, but not the real commands to perform the action for real. Do not use the following commands, unless they are run with the `--dry-run` flag, or similar flag:
- `nix flake update`
- `darwin-rebuild switch ...`
- `home-manager switch ...`
- `nixos-rebuild switch ...`

Keep `docs/ai/conversations/dendritic_conversation.md` nearby for detailed rationale and examples from the original discussion.
