{ config, pkgs, ... }:

let android-nixpkgs = pkgs.callPackage (import (builtins.fetchGit {
    url = "https://github.com/tadfisher/android-nixpkgs.git";
    ref = "main";
  })) {
    channel = "stable";
  };

  android-sdk = android-nixpkgs.sdk (sdkPkgs: with sdkPkgs; [
      cmdline-tools-latest
      platform-tools
      emulator

      build-tools-34-0-0
      platforms-android-34

      build-tools-35-0-0
      platforms-android-35

      build-tools-36-0-0
      platforms-android-36
    ]);
in
{
  environment.systemPackages = with pkgs; [
    android-studio
    android-sdk
    android-tools
  ];

  programs.adb.enable = true;

  environment.sessionVariables = {
    ANDROID_HOME = "${android-sdk}/share/android-sdk";
    ANDROID_SDK_ROOT = "${android-sdk}/share/android-sdk";
  };
}
