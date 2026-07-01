{ config, pkgs, ... }:

let
  # =====================================================================
  # --- 1. ANDROID SDK (μέσω android-nixpkgs) ---
  # =====================================================================
  android-nixpkgs = pkgs.callPackage (import (builtins.fetchGit {
    url = "https://github.com/tadfisher/android-nixpkgs.git";
    ref = "main";
  })) {
    channel = "stable";
  };

  my-android-sdk = android-nixpkgs.sdk (sdkPkgs: with sdkPkgs; [
    cmdline-tools-latest
    build-tools-34-0-0
    platform-tools
    platforms-android-34
    emulator
  ]);
in
{
  imports =
    [ ./hardware-configuration.nix ];

  # --- ΕΠΙΤΡΕΠΟΥΜΕ ΙΔΙΟΚΤΗΣΙΑΚΟ ΛΟΓΙΣΜΙΚΟ ---
  nixpkgs.config.allowUnfree = true;

  # =====================================================================
  # [ΚΡΑΤΗΣΕ ΕΔΩ ΤΙΣ ΔΙΚΕΣ ΣΟΥ ΡΥΘΜΙΣΕΙΣ ΓΙΑ BOOTLOADER ΚΑΙ ΗΧΟ]
  # =====================================================================

  # =====================================================================
  # --- INTEL GRAPHICS & VULKAN (NixOS 26.xx syntax) ---
  # =====================================================================
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Απαραίτητο για Steam/Wine κλπ.
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
      vulkan-validation-layers
    ];
  };

  # =====================================================================
  # --- SERVICES (Tailscale & i3 Window Manager) ---
  # =====================================================================
  services.tailscale.enable = true;

  services.xserver = {
    enable = true;

    # Ρύθμιση πληκτρολογίου
    xkb = {
      layout = "us,gr";
      options = "grp:alt_shift_toggle";
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        i3status
        i3lock
      ];
    };
  };

  # ΠΡΟΣΟΧΗ: Στις εκδόσεις 26.xx ο Display Manager βρίσκεται εδώ
  services.displayManager.lightdm.enable = true;

  # --- ΕΝΕΡΓΟΠΟΙΗΣΗ ADB ---
  programs.adb.enable = true;

  # =====================================================================
  # --- USER CONFIGURATION ---
  # =====================================================================
  users.users.giorgos = {
    isNormalUser = true;
    description = "Γιώργος";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "adbusers" ];
    packages = with pkgs; [
      firefox
    ];
  };

  # =====================================================================
  # --- TERMINAL & SHELLS (Zsh, Starship, Zoxide) ---
  # =====================================================================
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.starship.enable = true;

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  environment.shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    ll = "ls -lh";
    la = "ls -lah";
    update = "sudo nixos-rebuild switch";
    clean = "sudo nix-collect-garbage -d";
    cat = "bat";
    ts = "tailscale status";
  };

  # =====================================================================
  # --- ENVIRONMENT VARIABLES ---
  # =====================================================================
  environment.sessionVariables = {
    ANDROID_HOME = "${my-android-sdk}/share/android-sdk";
    ANDROID_SDK_ROOT = "${my-android-sdk}/share/android-sdk";
  };

  # =====================================================================
  # --- SYSTEM PACKAGES ---
  # =====================================================================
  environment.systemPackages = with pkgs; [
    # WM Utilities
    rofi
    dmenu

    # Dev Tools
    go
    rustup
    gcc

    # Editors & IDEs
    zed-editor
    android-studio
    my-android-sdk

    # Terminal Utilities
    btop
    bat
    wget
    curl
    git
    vulkan-tools
    libva-utils

    # Doom Emacs Dependencies
    emacs
    ripgrep
    fd
    coreutils
    clang
    cmake
    libtool
  ];

  # =====================================================================
  # --- SMART DOOM EMACS AUTOMATIC INSTALLATION ---
  # =====================================================================
  system.activationScripts.ensureDoomEmacs = {
    deps = [];
    text = ''
      EMACS_DIR="/home/giorgos/.config/emacs"

      if [ ! -d "$EMACS_DIR" ]; then
        echo "Doom Emacs not found. Installing..."
        ${pkgs.git}/bin/git clone --depth 1 https://github.com/doomemacs/doomemacs "$EMACS_DIR"
        "$EMACS_DIR/bin/doom" install --noninteractive
        chown -R giorgos:users "$EMACS_DIR"
      else
        echo "Doom Emacs already installed. Skipping..."
      fi
    '';
  };

  # =====================================================================
  # --- STATE VERSION ---
  # =====================================================================
  system.stateVersion = "26.05";
}
