# Cross-Platform Application Management

This document describes how application management works across macOS (Darwin) and Linux (NixOS) in this configuration.

## Problem Solved

### macOS Issues
- Applications installed via Nix lose Camera, Microphone, and Screen Recording permissions when updating
- macOS TCC (Transparency, Consent, and Control) tracks permissions by file path
- Each Nix update creates new `/nix/store/` paths, resetting permissions

### Linux Issues
- Desktop entries not always created correctly
- Wayland/X11 compatibility issues with Electron apps
- Applications not appearing in application menus

## Solution Architecture

### 1. Platform-Specific Modules

#### macOS Only
- **`modules/darwin-tcc-permissions.nix`**: Manages TCC permission backup/restore
- **`modules/mac-app-wrappers.nix`**: Creates stable wrapper scripts at `/usr/local/bin/`
- **TCC Profile**: `hosts/crackbookpro/etc/tcc-pppc.mobileconfig` pre-grants permissions

#### Cross-Platform
- **`modules/cross-platform-apps.nix`**: Universal wrapper and desktop entry management
- Works on both Darwin and Linux systems
- Automatically detects platform and applies appropriate configurations

### 2. Helper Scripts

#### Universal Script
- **`bin/fix-apps`**: Detects platform and runs appropriate fixer

#### Platform-Specific Scripts
- **`bin/fix-permissions`**: macOS permission fixer
- **`bin/fix-linux-apps`**: Linux application and desktop entry fixer

### 3. Shell Integration
- ZSH configuration automatically adds platform-specific paths
- Linux: Adds `~/.local/bin` to PATH, sets `NIXOS_OZONE_WL=1`
- macOS: Adds `/usr/local/bin` to PATH

## Configuration

### Enable on macOS (Darwin)
```nix
# hosts/crackbookpro/darwin.nix
{
  # TCC permission management
  services.tccPermissions = {
    enable = true;
    autoBackup = true;
    autoRestore = true;
    applications = [ "brave" "slack" "zoom" "vscode" ];
  };
  
  # Stable app wrappers
  services.macAppWrappers = {
    enable = true;
    applications = [ "brave" "slack" "zoom" "vscode" ];
  };
  
  # Cross-platform management
  services.crossPlatformApps = {
    enable = true;
    applications = [ "brave" "slack" "vscode" "firefox" ];
    createWrappers = true;
    persistentPaths = true;
  };
}
```

### Enable on NixOS/Linux
```nix
# hosts/thinkpad/configuration.nix
{
  services.crossPlatformApps = {
    enable = true;
    applications = [ "brave" "slack" "vscode" "firefox" ];
    createWrappers = true;
    createDesktopEntries = true;
    persistentPaths = false;  # Not needed on Linux
  };
}
```

## Usage

### After System Update

#### macOS
```bash
# If permissions are lost after update
fix-permissions

# Or just fix apps
fix-apps

# Check permission status
tcc-status

# Manual backup/restore
tcc-backup
tcc-restore
```

#### Linux
```bash
# Fix desktop entries and app issues
fix-linux-apps

# Or use universal script
fix-apps
```

### Application Launch

Applications are available via multiple methods:

1. **Wrapper Scripts**: `nix-brave`, `nix-slack`, etc.
2. **Direct Names**: `brave`, `slack` (via symlinks)
3. **GUI**: Applications appear in system menus
4. **macOS**: Apps in `~/Applications/Home Manager Apps/`

## How It Works

### macOS Flow
1. **Before Update**: TCC permissions automatically backed up
2. **During Update**: New `/nix/store/` paths created
3. **After Update**: 
   - Permissions restored from backup
   - Stable wrappers at `/usr/local/bin/` maintain consistent paths
   - TCC profile ensures permissions can be granted
4. **On Launch**: Wrapper resolves to current Nix store path

### Linux Flow
1. **During Build**: Desktop entries created for each app
2. **After Update**:
   - Desktop database updated
   - Symlinks created in `~/.local/bin/`
   - Environment variables set for Wayland/X11
3. **On Launch**: Wrapper handles platform-specific requirements

## Troubleshooting

### macOS Issues

**Permissions not sticking:**
1. Run `fix-permissions`
2. Open System Preferences > Security & Privacy
3. Grant permissions to apps starting with "nix-"
4. Restart affected applications

**Apps not found:**
- Check `which nix-appname`
- Verify app is in configuration
- Run `darwin-rebuild switch --flake .`

### Linux Issues

**Apps not in menu:**
1. Run `fix-linux-apps`
2. Log out and back in
3. Or restart your desktop environment

**Wayland issues:**
- Apps should auto-detect Wayland (NIXOS_OZONE_WL=1)
- Force X11: `nix-app --ozone-platform=x11`

**Screen sharing on Wayland:**
- Ensure `xdg-desktop-portal` is installed
- Install appropriate portal for your DE

## Adding New Applications

1. Add to appropriate host configuration:
```nix
services.crossPlatformApps.applications = [ 
  "brave" 
  "slack" 
  "vscode" 
  "firefox"
  "new-app"  # Add here
];
```

2. If macOS, also add to TCC modules:
```nix
services.tccPermissions.applications = [ ..., "new-app" ];
services.macAppWrappers.applications = [ ..., "new-app" ];
```

3. Add app configuration to `modules/cross-platform-apps.nix`:
```nix
appConfigs = {
  # ...
  "new-app" = {
    package = pkgs.new-app;
    bundleId = "com.company.newapp";  # macOS bundle ID
    linuxExec = "new-app";            # Linux executable name
    icon = "new-app";                 # Icon name for desktop entry
  };
};
```

4. Rebuild system:
```bash
# macOS
darwin-rebuild switch --flake .

# NixOS
sudo nixos-rebuild switch --flake .
```

## Benefits

1. **Persistent Permissions**: macOS permissions survive Nix updates
2. **Consistent UX**: Same commands work across platforms
3. **Automatic Management**: Minimal manual intervention required
4. **Fallback Options**: Multiple ways to launch applications
5. **Clean Integration**: Works with existing Nix tooling

## Technical Details

### File Locations

**macOS:**
- Wrappers: `/usr/local/bin/nix-*`
- App aliases: `~/Applications/Home Manager Apps/`
- TCC backup: `/var/lib/tcc-permissions-backup.db`
- TCC database: `/Library/Application Support/com.apple.TCC/TCC.db`

**Linux:**
- Wrappers: `~/.local/bin/nix-*`
- Desktop entries: `~/.local/share/applications/`
- Environment: `~/.config/environment.d/`

### Security Considerations

- TCC scripts require sudo on macOS
- Wrappers maintain original app security contexts
- No modification of system files outside Nix store
- Configuration profiles follow Apple's standards