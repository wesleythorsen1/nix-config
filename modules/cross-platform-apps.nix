{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.crossPlatformApps;
  
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  
  # Desktop file generator for Linux
  mkDesktopEntry = name: exec: icon: comment: pkgs.makeDesktopItem {
    inherit name exec icon comment;
    desktopName = name;
    genericName = name;
    categories = [ "Network" "Office" ];
    mimeTypes = [ ];
  };
  
  # Wrapper script generator that works on both platforms
  mkUniversalWrapper = name: package: bundleId: pkgs.writeScriptBin "nix-${name}" ''
    #!${pkgs.bash}/bin/bash
    # Universal wrapper for ${name} that maintains consistent behavior across platforms
    
    ${if isDarwin then ''
      # macOS-specific logic
      APP_PATH=""
      
      # Try to find via nix profile
      if command -v ${name} &> /dev/null; then
        RESOLVED=$(readlink -f "$(which ${name})")
        if [[ "$RESOLVED" == *"/nix/store/"* ]]; then
          APP_DIR=$(echo "$RESOLVED" | sed 's|/Contents/MacOS/.*|.app|')
          if [ -d "$APP_DIR" ]; then
            APP_PATH="$APP_DIR"
          fi
        fi
      fi
      
      # Search in common locations
      if [ -z "$APP_PATH" ]; then
        for dir in \
          "$HOME/Applications/Home Manager Apps" \
          "$HOME/Applications" \
          "/Applications" \
          "/nix/store/"*"-${name}-"*"/Applications"; do
          if [ -d "$dir/${name}.app" ]; then
            APP_PATH="$dir/${name}.app"
            break
          fi
        done
      fi
      
      if [ -n "$APP_PATH" ]; then
        exec open -a "$APP_PATH" "$@"
      else
        # Fallback to direct execution
        exec ${package}/bin/${name} "$@" 2>/dev/null || \
        exec ${package}/bin/${lib.toLower name} "$@" 2>/dev/null || \
        echo "Error: Could not find ${name}" >&2
      fi
    '' else ''
      # Linux-specific logic
      # Set up environment for better integration
      export NIXOS_OZONE_WL=1  # Enable Wayland support for Electron apps
      
      # Try direct execution
      if [ -x "${package}/bin/${name}" ]; then
        exec ${package}/bin/${name} "$@"
      elif [ -x "${package}/bin/${lib.toLower name}" ]; then
        exec ${package}/bin/${lib.toLower name} "$@"
      else
        # Search for the binary
        BIN=$(find ${package}/bin -type f -executable | head -n1)
        if [ -n "$BIN" ]; then
          exec "$BIN" "$@"
        else
          echo "Error: Could not find executable for ${name}" >&2
          exit 1
        fi
      fi
    ''}
  '';
  
  # Application configurations
  appConfigs = {
    brave = {
      package = pkgs.brave;
      bundleId = "com.brave.Browser";
      linuxExec = "brave";
      icon = "brave-browser";
    };
    slack = {
      package = pkgs.slack;
      bundleId = "com.tinyspeck.slackmacgap";
      linuxExec = "slack";
      icon = "slack";
    };
    zoom = {
      package = pkgs.zoom-us or null;
      bundleId = "us.zoom.xos";
      linuxExec = "zoom";
      icon = "zoom";
    };
    vscode = {
      package = pkgs.vscode;
      bundleId = "com.microsoft.VSCode";
      linuxExec = "code";
      icon = "code";
    };
    firefox = {
      package = pkgs.firefox;
      bundleId = "org.mozilla.firefox";
      linuxExec = "firefox";
      icon = "firefox";
    };
  };

in {
  options.services.crossPlatformApps = {
    enable = mkEnableOption "Cross-platform application wrappers and management";
    
    applications = mkOption {
      type = types.listOf (types.enum (attrNames appConfigs));
      default = [ "brave" "slack" "vscode" ];
      description = "List of applications to manage across platforms";
    };
    
    createWrappers = mkOption {
      type = types.bool;
      default = true;
      description = "Create wrapper scripts for applications";
    };
    
    createDesktopEntries = mkOption {
      type = types.bool;
      default = isLinux;
      description = "Create desktop entries for Linux systems";
    };
    
    persistentPaths = mkOption {
      type = types.bool;
      default = isDarwin;
      description = "Create persistent paths for macOS TCC permissions";
    };
  };
  
  config = mkIf cfg.enable {
    # Add wrapper scripts to packages
    environment.systemPackages = 
      (if cfg.createWrappers then
        filter (x: x != null) (map (app: 
          if appConfigs.${app}.package != null then
            mkUniversalWrapper app appConfigs.${app}.package appConfigs.${app}.bundleId
          else
            null
        ) cfg.applications)
      else []) ++
      (if (isLinux && cfg.createDesktopEntries) then
        filter (x: x != null) (map (app:
          if appConfigs.${app}.package != null then
            mkDesktopEntry 
              app 
              "nix-${app}"
              appConfigs.${app}.icon
              "${app} via Nix"
          else
            null
        ) cfg.applications)
      else []);
    
    # Platform-specific activation scripts
    system.activationScripts = mkMerge [
      # macOS activation
      (mkIf isDarwin {
        crossPlatformAppsMacOS = {
          text = ''
            echo "Setting up cross-platform application wrappers for macOS..."
            
            # Create stable symlinks in /usr/local/bin
            mkdir -p /usr/local/bin
            
            ${concatMapStrings (app: ''
              if [ ! -f "/usr/local/bin/nix-${app}" ]; then
                echo "Creating stable wrapper for ${app}"
                cat > "/usr/local/bin/nix-${app}" << 'EOF'
            #!/bin/bash
            # Stable wrapper for ${app}
            exec ${config.system.path}/bin/nix-${app} "$@"
            EOF
                chmod +x "/usr/local/bin/nix-${app}"
              fi
            '') cfg.applications}
            
            echo "Cross-platform application setup complete for macOS"
          '';
        };
      })
      
      # Linux activation
      (mkIf isLinux {
        crossPlatformAppsLinux = {
          text = ''
            echo "Setting up cross-platform application wrappers for Linux..."
            
            # Ensure XDG directories exist
            mkdir -p $HOME/.local/share/applications
            mkdir -p $HOME/.local/bin
            
            ${concatMapStrings (app: ''
              # Create user-level wrapper symlink
              if [ ! -f "$HOME/.local/bin/nix-${app}" ]; then
                ln -sf ${config.system.path}/bin/nix-${app} $HOME/.local/bin/nix-${app}
              fi
              
              # Update desktop database
              if command -v update-desktop-database &> /dev/null; then
                update-desktop-database $HOME/.local/share/applications 2>/dev/null || true
              fi
            '') cfg.applications}
            
            echo "Cross-platform application setup complete for Linux"
          '';
        };
      })
    ];
    
  };
}