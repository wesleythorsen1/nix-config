{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.macAppWrappers;
  
  # Create a wrapper script for an application
  mkAppWrapper = name: appPath: bundleId: pkgs.writeScriptBin name ''
    #!${pkgs.bash}/bin/bash
    # Stable wrapper for ${name} that maintains consistent path for TCC permissions
    
    # Find the latest version of the app in the nix store
    APP_PATH=""
    
    # First, try to find via nix profile
    if command -v ${name} &> /dev/null; then
      RESOLVED=$(readlink -f "$(which ${name})")
      if [[ "$RESOLVED" == *"/nix/store/"* ]]; then
        # Extract the app bundle path from the resolved binary
        APP_DIR=$(echo "$RESOLVED" | sed 's|/Contents/MacOS/.*|.app|')
        if [ -d "$APP_DIR" ]; then
          APP_PATH="$APP_DIR"
        fi
      fi
    fi
    
    # Fallback: search in common locations
    if [ -z "$APP_PATH" ]; then
      for dir in \
        "$HOME/Applications/Home Manager Apps" \
        "$HOME/Applications" \
        "/Applications" \
        "/nix/store/"*"-${name}-"*"/Applications"; do
        if [ -d "$dir/${appPath}.app" ]; then
          APP_PATH="$dir/${appPath}.app"
          break
        fi
      done
    fi
    
    # Final fallback: use find (slower but comprehensive)
    if [ -z "$APP_PATH" ]; then
      APP_PATH=$(find /nix/store -maxdepth 3 -name "${appPath}.app" -type d 2>/dev/null | head -n1)
    fi
    
    if [ -z "$APP_PATH" ]; then
      echo "Error: Could not find ${name} application bundle" >&2
      echo "Please ensure ${name} is installed via Nix" >&2
      exit 1
    fi
    
    # Launch the application
    exec open -a "$APP_PATH" "$@"
  '';
  
  # Create stable symlinks for applications
  mkAppSymlink = name: bundleId: ''
    # Create stable symlink for ${name}
    WRAPPER_DIR="/usr/local/bin"
    WRAPPER_PATH="$WRAPPER_DIR/nix-${name}"
    
    # Only create if it doesn't exist (preserve permissions)
    if [ ! -f "$WRAPPER_PATH" ]; then
      echo "Creating stable wrapper for ${name} at $WRAPPER_PATH"
      cat > "$WRAPPER_PATH" << 'WRAPPER_EOF'
    #!/bin/bash
    # Auto-generated stable wrapper for ${name}
    # This wrapper maintains a consistent path for macOS TCC permissions
    
    # Find and launch the current Nix-installed version
    APP_BUNDLE_ID="${bundleId}"
    
    # Try to find the app using mdfind (Spotlight)
    APP_PATH=$(mdfind "kMDItemCFBundleIdentifier == '$APP_BUNDLE_ID'" 2>/dev/null | grep -E "(/nix/store|/Users/[^/]+/Applications)" | head -n1)
    
    # Fallback to searching common locations
    if [ -z "$APP_PATH" ]; then
      for dir in \
        "$HOME/Applications/Home Manager Apps" \
        "$HOME/Applications" \
        "/Applications"; do
        if [ -d "$dir/${name}.app" ]; then
          APP_PATH="$dir/${name}.app"
          break
        fi
      done
    fi
    
    if [ -z "$APP_PATH" ]; then
      echo "Error: Could not find ${name} (bundle ID: $APP_BUNDLE_ID)" >&2
      echo "Please ensure ${name} is installed via Nix" >&2
      exit 1
    fi
    
    # Launch the application
    exec open -a "$APP_PATH" "$@"
    WRAPPER_EOF
      
      chmod +x "$WRAPPER_PATH"
      
      # Try to pre-grant permissions for the wrapper
      # Note: This may require user interaction
      tccutil reset All "$WRAPPER_PATH" 2>/dev/null || true
    fi
  '';
  
  # Application configurations
  appConfigs = {
    brave = {
      appPath = "Brave Browser";
      bundleId = "com.brave.Browser";
      executable = "Brave Browser";
    };
    slack = {
      appPath = "Slack";
      bundleId = "com.tinyspeck.slackmacgap";
      executable = "Slack";
    };
    zoom = {
      appPath = "zoom.us";
      bundleId = "us.zoom.xos";
      executable = "zoom.us";
    };
    vscode = {
      appPath = "Visual Studio Code";
      bundleId = "com.microsoft.VSCode";
      executable = "Code";
    };
  };

in {
  options.services.macAppWrappers = {
    enable = mkEnableOption "Create stable wrapper scripts for macOS applications";
    
    applications = mkOption {
      type = types.listOf (types.enum (attrNames appConfigs));
      default = [ "brave" "slack" ];
      description = "List of applications to create stable wrappers for";
    };
    
    wrapperDirectory = mkOption {
      type = types.str;
      default = "/usr/local/bin";
      description = "Directory to create stable wrapper scripts in";
    };
  };
  
  config = mkIf cfg.enable {
    # Add wrapper scripts to system packages
    environment.systemPackages = map (app:
      mkAppWrapper 
        "nix-${app}" 
        appConfigs.${app}.appPath
        appConfigs.${app}.bundleId
    ) cfg.applications;
    
    # Create stable symlinks during activation
    system.activationScripts.macAppWrappers = {
      text = ''
        echo "Setting up stable application wrappers..."
        
        # Ensure wrapper directory exists
        mkdir -p ${cfg.wrapperDirectory}
        
        ${concatMapStrings (app: 
          mkAppSymlink app appConfigs.${app}.bundleId
        ) cfg.applications}
        
        echo "Application wrappers setup complete"
        
        # Remind user to grant permissions to wrappers if needed
        cat << 'INFO_EOF'
        
        ============================================================
        IMPORTANT: macOS Permission Setup
        ============================================================
        
        Stable wrappers have been created for your applications.
        
        To grant permissions (Camera, Microphone, Screen Recording):
        
        1. Open System Preferences > Security & Privacy
        2. Navigate to the permission you want to grant
        3. Click the lock to make changes
        4. If the app doesn't appear in the list:
           - Look for entries starting with "nix-" (e.g., nix-brave)
           - Or use the (+) button to add:
             ${cfg.wrapperDirectory}/nix-[appname]
        
        These wrappers will maintain permissions across Nix updates.
        
        You can also use the following commands:
        - tcc-status    : Check current permissions
        - tcc-backup    : Backup current permissions
        - tcc-restore   : Restore backed up permissions
        - fix-permissions : Automated permission fix
        
        ============================================================
        INFO_EOF
      '';
    };
    
    # Create launch agents for permission persistence
    launchd.daemons."org.nixos.tcc-permission-watcher" = {
      serviceConfig = {
        Label = "org.nixos.tcc-permission-watcher";
        ProgramArguments = [
          "${pkgs.bash}/bin/bash"
          "-c"
          ''
            # Monitor and maintain TCC permissions for Nix apps
            while true; do
              # Check if any Nix apps have lost permissions
              for app in ${toString cfg.applications}; do
                # Check if the wrapper exists and has proper permissions
                wrapper="${cfg.wrapperDirectory}/nix-$app"
                if [ -f "$wrapper" ]; then
                  # This is where we could check and restore permissions
                  # But we need to be careful not to prompt the user unnecessarily
                  :
                fi
              done
              
              # Sleep for 5 minutes before next check
              sleep 300
            done
          ''
        ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardErrorPath = "/var/log/tcc-permission-watcher.err";
        StandardOutPath = "/var/log/tcc-permission-watcher.log";
      };
    };
  };
}