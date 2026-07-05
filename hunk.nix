{ config, pkgs, ... }:

let hunk-src = pkgs.fetchFromGitHub {
    owner = "modem-dev";
    repo = "hunk";
    rev = "main";

    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };
  hunk-package = pkgs.callPackage "${hunk-src}/nix" {};
in
{
  environment.systemPackages = with pkgs; [
    hunk-package  # <-- ΕΔΩ ΒΑΖΟΥΜΕ ΤΟ CUSTOM ΠΑΚΕΤΟ (όχι το σκέτο hunk!)
  ];
}
