{
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    # ./nvidia.nix
  ];

  # Bootloader - Basic system settings
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # # old, delete if not needed:
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "thinkpad"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  services.xserver = {
    enable = true;
    # Use Intel iGPU for now; comment out if you want NVIDIA PRIME later
    videoDrivers = [ "modesetting" ];

    displayManager = {
      sddm.enable = true;
      # Explicitly disable LightDM
      lightdm.enable = false;
      # Boot into XFCE for stability
      defaultSession = "xfce";
    };

    desktopManager.xfce.enable = true;
  };

  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # User accounts
  users.users.wes = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
    ];
    shell = pkgs.zsh;
  };

  # Misc services
  services.openssh.enable = true;
  services.printing.enable = true;

  # Optional: get rid of those noisy dbus/acpid errors
  services.resolved.enable = true;
  services.acpid.enable = true;

  # Allow unfree packages (for NVIDIA if you later want it)
  nixpkgs.config.allowUnfree = true;

  # Packages
  environment.systemPackages = with pkgs; [
    # vim
    # git
    wget
    # firefox
    xfce.thunar
    xfce.mousepad
  ];

  programs = {
    zsh.enable = true;

    # Disable Hyprland for now to avoid crashes
    hyprland.enable = lib.mkForce false;
  };

  system.stateVersion = "25.05"; # Did you read the comment?

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };
}
