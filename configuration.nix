{ config, pkgs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ./services.nix
      ./aliases.nix
      ./fonts.nix
      ./open_plc.nix
      ./android_studio.nix
  ];

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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "thinkpad_t480s";
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

  users.users.giorgos = {
    isNormalUser = true;
    description = "Giwrgis";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "adbusers" "kvm" "docker" ];
    packages = with pkgs; [ firefox-devedition ];
  };

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

  programs.java = {
    enable = true;
    package = pkgs.jdk21;
  };

  environment.systemPackages = with pkgs; [
    (polybar.override { i3Support = true; })

    rofi
    arandr
    feh
    dunst
    stow

    # Dev Tools
    git
    curl
    fzf
    ffmpeg

    # Terminal Utilities
    bat
    eza

    #Zed Dependencies
    zed-editor
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

    #Terminals
    ghostty
    kitty

    #TUIs
    gh
    btop
    yazi
    lazygit
    posting
    lazydocker

    #Languages
    go
    java
    rustup

    #Language servers
    nil
    nixd
    gopls

    #Browsers
    chromium
    firefox-devedition

    #General programms
    flameshot
    discord
    cheese
    vlc
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";
}
