{
  pkgs,
  unstable-overlay,
  a71323f-overlay,
  vscode-overlay,
  ...
}:

# System-level macOS configuration for crackbookpro
{
  # Apply overlays and allow unfree packages
  nixpkgs.overlays = [ unstable-overlay a71323f-overlay vscode-overlay ];
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "crackbookpro";

  # Configure the user account
  users.users.wes = {
    home  = "/Users/wes";
    shell = pkgs.zsh;
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;

  # Ensure the Nix daemon runs on startup
  services.nix-daemon.enable = true;

  system.stateVersion = 5;

  # Common macOS defaults
  system.defaults = {
    NSGlobalDomain.AppleShowAllExtensions = true;  # Show file extensions
    dock.autohide                  = true;         # Auto-hide the Dock
  };

  # Enable Nix experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Global system packages
  environment.systemPackages = with pkgs; [
    git
    coreutils
  ];
}
