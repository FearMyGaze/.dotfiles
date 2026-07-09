{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # --- INTEL GRAPHICS & VULKAN ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # --- BOOTLOADER (Systemd-boot & explicit GRUB disable) ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false; # Κλειδώνουμε ότι δεν θα ζητήσει GRUB

  # --- NETWORK & LOCALES ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Athens";
  i18n.defaultLocale = "en_US.UTF-8";

  # --- SERVICES (X11 & i3) ---
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us,gr";
      options = "grp:alt_shift_toggle";
    };
    windowManager.i3.enable = true;
  };

  # Προσωρινός minimal Display Manager για να αποφύγουμε θέματα με το LightDM στο live περιβάλλον
  services.displayManager.ly.enable = true;

  # Ήχος
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # --- USER ---
  users.users.giorgos = {
    isNormalUser = true;
    description = "Γιώργος";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  programs.zsh.enable = true;

  # --- MINIMAL SYSTEM PACKAGES (Μόνο τα βασικά για την εγκατάσταση) ---
  environment.systemPackages = with pkgs; [
    nano
    git
    wget
    curl
    btop
    firefox # Για να έχεις browser μόλις μπεις
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  fonts.enableDefaultPackages = true; # Διορθωμένο για 26.05
  system.stateVersion = "26.05";
}
