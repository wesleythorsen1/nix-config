{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.tccPermissions;
  
  tccDbPath = "/Library/Application Support/com.apple.TCC/TCC.db";
  backupPath = "/var/lib/tcc-permissions-backup.db";
  
  # Bundle IDs for applications that need permissions
  appBundleIds = {
    brave = "com.brave.Browser";
    slack = "com.tinyspeck.slackmacgap";
    zoom = "us.zoom.xos";
    vscode = "com.microsoft.VSCode";
  };
  
  # Helper script to backup TCC permissions
  backupTccScript = pkgs.writeScriptBin "tcc-backup" ''
    #!${pkgs.bash}/bin/bash
    set -e
    
    echo "Backing up TCC permissions..."
    
    # Create backup directory if it doesn't exist
    sudo mkdir -p "$(dirname "${backupPath}")"
    
    # Copy the TCC database
    if [ -f "${tccDbPath}" ]; then
      sudo cp "${tccDbPath}" "${backupPath}"
      echo "TCC permissions backed up to ${backupPath}"
    else
      echo "TCC database not found at ${tccDbPath}"
      exit 1
    fi
    
    # Also export human-readable backup
    sudo sqlite3 "${tccDbPath}" <<EOF > /tmp/tcc-permissions.txt
.mode csv
.headers on
SELECT service, client, auth_value, auth_reason 
FROM access 
WHERE client IN ('${appBundleIds.brave}', '${appBundleIds.slack}', '${appBundleIds.zoom}', '${appBundleIds.vscode}')
  AND service IN ('kTCCServiceCamera', 'kTCCServiceMicrophone', 'kTCCServiceScreenCapture');
EOF
    
    echo "Human-readable backup saved to /tmp/tcc-permissions.txt"
  '';
  
  # Helper script to restore TCC permissions
  restoreTccScript = pkgs.writeScriptBin "tcc-restore" ''
    #!${pkgs.bash}/bin/bash
    set -e
    
    echo "Restoring TCC permissions..."
    
    if [ ! -f "${backupPath}" ]; then
      echo "No backup found at ${backupPath}"
      echo "Run 'tcc-backup' first to create a backup"
      exit 1
    fi
    
    # Function to grant permission using tccutil
    grant_permission() {
      local service=$1
      local bundle_id=$2
      
      echo "Granting $service permission to $bundle_id..."
      
      # Reset first to clear any existing entries
      sudo tccutil reset "$service" "$bundle_id" 2>/dev/null || true
      
      # Try to restore from backup
      sudo sqlite3 "${tccDbPath}" <<EOF 2>/dev/null || true
INSERT OR REPLACE INTO access (service, client, client_type, auth_value, auth_reason, auth_version)
SELECT service, client, client_type, auth_value, auth_reason, auth_version
FROM (SELECT * FROM "${backupPath}".access 
      WHERE client = '$bundle_id' 
        AND service = '$service'
      LIMIT 1);
EOF
    }
    
    # Restore permissions for each app and service
    for bundle_id in "${appBundleIds.brave}" "${appBundleIds.slack}" "${appBundleIds.zoom}" "${appBundleIds.vscode}"; do
      grant_permission "kTCCServiceCamera" "$bundle_id"
      grant_permission "kTCCServiceMicrophone" "$bundle_id"
      grant_permission "kTCCServiceScreenCapture" "$bundle_id"
    done
    
    echo "TCC permissions restore completed"
    echo "You may need to restart the affected applications"
  '';
  
  # Script to check current TCC status
  statusTccScript = pkgs.writeScriptBin "tcc-status" ''
    #!${pkgs.bash}/bin/bash
    
    echo "Current TCC Permissions Status:"
    echo "==============================="
    
    # Check if running with sufficient privileges
    if ! sudo -n true 2>/dev/null; then
      echo "This script requires sudo access to read TCC database"
      sudo -v
    fi
    
    # Query the TCC database
    sudo sqlite3 "${tccDbPath}" <<EOF 2>/dev/null || echo "Unable to read TCC database"
.mode column
.headers on
.width 25 35 12 12
SELECT 
  service,
  client,
  CASE auth_value 
    WHEN 0 THEN 'Denied'
    WHEN 1 THEN 'Unknown'
    WHEN 2 THEN 'Allowed'
    WHEN 3 THEN 'Limited'
    ELSE 'Unknown'
  END as permission,
  CASE auth_reason
    WHEN 0 THEN 'User'
    WHEN 1 THEN 'System'
    WHEN 2 THEN 'Service'
    WHEN 3 THEN 'MDM'
    WHEN 4 THEN 'Override'
    ELSE 'Unknown'
  END as reason
FROM access 
WHERE client IN ('${appBundleIds.brave}', '${appBundleIds.slack}', '${appBundleIds.zoom}', '${appBundleIds.vscode}')
  AND service IN ('kTCCServiceCamera', 'kTCCServiceMicrophone', 'kTCCServiceScreenCapture')
ORDER BY client, service;
EOF
    
    echo ""
    echo "Note: If an app is not listed, it has no permissions set"
  '';

in {
  options.services.tccPermissions = {
    enable = mkEnableOption "TCC permissions management for Nix-installed applications";
    
    autoBackup = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically backup TCC permissions before system rebuild";
    };
    
    autoRestore = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically restore TCC permissions after system rebuild";
    };
    
    applications = mkOption {
      type = types.listOf types.str;
      default = [ "brave" "slack" "zoom" "vscode" ];
      description = "List of applications to manage TCC permissions for";
    };
  };
  
  config = mkIf cfg.enable {
    environment.systemPackages = [
      backupTccScript
      restoreTccScript
      statusTccScript
      pkgs.sqlite
    ];
    
    # Pre-activation script to backup permissions
    system.activationScripts.preActivation.text = mkIf cfg.autoBackup ''
      echo "Backing up TCC permissions before rebuild..."
      if [ -f "${tccDbPath}" ]; then
        mkdir -p "$(dirname "${backupPath}")"
        cp "${tccDbPath}" "${backupPath}" 2>/dev/null || true
      fi
    '';
    
    # Post-activation script to restore permissions
    system.activationScripts.postActivation.text = mkIf cfg.autoRestore ''
      echo "Checking TCC permissions after rebuild..."
      
      # Give the system a moment to settle
      sleep 2
      
      # Check if backup exists and restore if needed
      if [ -f "${backupPath}" ]; then
        echo "Restoring TCC permissions from backup..."
        
        # Function to check and restore permission
        check_and_restore() {
          local service=$1
          local bundle_id=$2
          
          # Check if permission exists
          existing=$(sqlite3 "${tccDbPath}" "SELECT auth_value FROM access WHERE service='$service' AND client='$bundle_id';" 2>/dev/null || echo "")
          
          if [ -z "$existing" ] || [ "$existing" != "2" ]; then
            # Permission missing or not allowed, try to restore
            backup_value=$(sqlite3 "${backupPath}" "SELECT auth_value FROM access WHERE service='$service' AND client='$bundle_id';" 2>/dev/null || echo "")
            
            if [ "$backup_value" = "2" ]; then
              echo "Restoring $service permission for $bundle_id..."
              sqlite3 "${tccDbPath}" <<SQL 2>/dev/null || true
INSERT OR REPLACE INTO access (service, client, client_type, auth_value, auth_reason, auth_version)
SELECT service, client, client_type, auth_value, auth_reason, auth_version
FROM (ATTACH DATABASE '${backupPath}' AS backup; 
      SELECT * FROM backup.access 
      WHERE client = '$bundle_id' 
        AND service = '$service'
      LIMIT 1);
SQL
            fi
          fi
        }
        
        # Restore permissions for configured applications
        ${concatMapStrings (app: ''
          if [[ " ''${cfg.applications[@]} " =~ " ${app} " ]]; then
            check_and_restore "kTCCServiceCamera" "${appBundleIds.${app}}"
            check_and_restore "kTCCServiceMicrophone" "${appBundleIds.${app}}"
            check_and_restore "kTCCServiceScreenCapture" "${appBundleIds.${app}}"
          fi
        '') (attrNames appBundleIds)}
        
        echo "TCC permissions check completed"
      fi
    '';
  };
}