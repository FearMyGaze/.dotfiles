# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

let
  # --- ANDROID SDK (μέσω android-nixpkgs) ---
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
  imports = [ ./hardware-configuration.nix ];

  # --- INTEL GRAPHICS & VULKAN ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
      vulkan-validation-layers
    ];
  };

  # --- SERVICES & THINKPAD OPTIMIZATIONS ---
  services.tailscale.enable = true;
  services.fwupd.enable = true;

  # --- FINGERPRINT SENSOR & PAM AUTHENTICATION ---
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.sudo.fprintAuth = true;

  # --- THINKPAD POWER MANAGEMENT (TLP) ---
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    };
  };

  # --- INTEL THERMAL MANAGEMENT ---
  services.thermald.enable = true;

  # --- TOUCHPAD & TRACKPOINT ---
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = true;
    };
  };

  # =========================================================================
  # 1. BOOTLOADER
  # =========================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # =========================================================================
  # 2. ΡΥΘΜΙΣΕΙΣ ΔΙΚΤΥΟΥ & ΓΛΩΣΣΑΣ (Locales)
  # =========================================================================
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Athens";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "el_GR.UTF-8";
    LC_IDENTIFICATION = "el_GR.UTF-8";
    LC_MEASUREMENT = "el_GR.UTF-8";
    LC_MONETARY = "el_GR.UTF-8";
    LC_NAME = "el_GR.UTF-8";
    LC_NUMERIC = "el_GR.UTF-8";
    LC_PAPER = "el_GR.UTF-8";
    LC_TELEPHONE = "el_GR.UTF-8";
    LC_TIME = "el_GR.UTF-8";
  };

  # =========================================================================
  # 3. SERVICES (Γραφικό Περιβάλλον, i3 & Ήχος)
  # =========================================================================
  services.xserver = {
    enable = true;

    # Ρύθμιση πληκτρολογίου (Εναλλαγή US / GR με Alt+Shift)
    xkb = {
      layout = "us,gr";
      variant = "";
      options = "grp:alt_shift_toggle";
    };

    # Ενεργοποίηση του i3 Window Manager
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        i3status
        i3lock
      ];
    };
  };

  # Επιστροφή στον ελαφρύ και σταθερό Ly Display Manager
  services.displayManager.ly.enable = true;

  # Ήχος μέσω Pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # =========================================================================
  # 4. ΔΙΑΧΕΙΡΙΣΗ ΧΡΗΣΤΩΝ
  # =========================================================================
  users.users.giorgos = {
    isNormalUser = true;
    description = "Γιώργος";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "adbusers" "docker" ];
    packages = with pkgs; [
      firefox
    ];
  };

  # --- TERMINAL & SHELLS ---
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

  # --- SHELL ALIASES ---
  environment.shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    ll = "eza -lh --icons";
    la = "eza -lah --icons";
    update = "sudo nixos-rebuild switch --flake /etc/nixos/#nixos --impure";
    clean = "sudo nix-collect-garbage -d";
    cat = "bat";
    ts = "tailscale status";
  };

  # --- ENVIRONMENT VARIABLES ---
  environment.sessionVariables = {
    ANDROID_HOME = "${my-android-sdk}/share/android-sdk";
    ANDROID_SDK_ROOT = "${my-android-sdk}/share/android-sdk";
  };

  # =========================================================================
  # 5. ΠΑΚΕΤΑ ΣΥΣΤΗΜΑΤΟΣ
  # =========================================================================
  environment.systemPackages = with pkgs; [
    (polybar.override { i3Support = true; })
    rofi
    dmenu
    arandr
    feh
    dunst

    # Dev Tools
    go
    rustup
    gcc
    gh
    fzf
    eza
    ghostty

    # Terminal Utilities
    btop
    bat
    curl
    git
    vulkan-tools
    libva-utils

    # Editors & IDEs
    zed-editor
    android-studio
    my-android-sdk
    android-tools

    # Doom Emacs Dependencies
    emacs
    ripgrep
    fd
    coreutils
    clang
    cmake
    libtool
    emacsPackages.pbcopy
    emacsPackages.vterm
    libvterm
    gdb
    gnumake
    libgcc
    pam_u2f
    ispell

    # Multimedia
    kdePackages.kdenlive
    obs-studio
    mesa
    flameshot
    chromium
    discord

    nil
  ];

  virtualisation.docker.enable = true;

  # --- FONTS ---
  fonts = {
    packages = with pkgs; [
      nerd-fonts.terminess-ttf
      nerd-fonts.blex-mono
      ibm-plex
      openmoji-color
    ];
    fontconfig = {
        defaultFonts = {
          sansSerif = [ "IBM Plex Sans" ];
          serif = [ "IBM Plex Serif" ];
          monospace = [ "Terminess Nerd Font" ];
          emoji = [ "OpenMoji Color" ];
        };
    };
    enableDefaultPackages = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";
}
