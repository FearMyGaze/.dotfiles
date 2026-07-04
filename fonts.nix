{ config, pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      nerd-fonts.terminess-ttf
      nerd-fonts.blex-mono
      ibm-plex
      openmoji-color
      maple-mono
    ];

    fontconfig = {
      defaultFonts = {
        sansSerif = [ "IBM Plex Sans" ];
        serif     = [ "IBM Plex Serif" ];
        monospace = [ "Terminess Nerd Font" ];
        emoji     = [ "Maple Mono NF" ];
      };
    };

    enableDefaultPackages = true;
  };
}
