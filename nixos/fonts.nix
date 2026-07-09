{ config, pkgs, ... }:

let sarasa-gothic-nerd = pkgs.stdenv.mkDerivation rec {
    pname = "sarasa-gothic-nerd";
    version = "1.0.37-0";

    src = pkgs.fetchurl {
      url = "https://github.com/jonz94/Sarasa-Gothic-Nerd-Fonts/releases/download/v${version}/sarasa-fixed-sc-nerd-font.zip";

      hash = "sha256-mfLSNMY5zGcG9WYCGgCzGrColAOh0h5Msd6h2oeVCKc=";
    };

    nativeBuildInputs = [ pkgs.unzip ];

    unpackPhase = ''
      unzip $src
    '';

    installPhase = ''
      mkdir -p $out/share/fonts/truetype/sarasa-nerd
      cp *.ttf $out/share/fonts/truetype/sarasa-nerd/ 2>/dev/null || cp *.ttc $out/share/fonts/truetype/sarasa-nerd/
    '';
  };
in
{
  fonts = {
    packages = with pkgs; [
      nerd-fonts.terminess-ttf
      nerd-fonts.blex-mono
      ibm-plex
      openmoji-color
      maple-mono.NF
      sarasa-gothic-nerd
    ];

    fontconfig = {
      defaultFonts = {
        sansSerif = [ "IBM Plex Sans" ];
        serif     = [ "IBM Plex Serif" ];
        monospace = [ "Sarasa Fixed SC Nerd Font" ];
        emoji     = [ "Maple Mono NF" ];
      };
    };

    enableDefaultPackages = true;
  };
}
