{ config, pkgs, ... }:

{
  # ====================================================================
  # 1. OPENPLC RUNTIME (ΜΕΣΩ DOCKER)
  # ====================================================================
  virtualisation.oci-containers = {
    backend = "docker";
    containers.openplc-runtime = {
      image = "autonomylogic/openplc-runtime:latest";
      ports = [ "8443:8443" ];
      volumes = [
        "openplc-data:/var/lib/openplc"
      ];
      autoStart = false;
      extraOptions = [ "--device=/dev/ttyUSB0" ];
    };
  };

  # ====================================================================
  # 2. OPENPLC EDITOR (APPIMAGE)
  # ====================================================================
  environment.systemPackages = [
    (pkgs.appimageTools.wrapType2 {
      pname = "openplc-editor";
      version = "4.2.8";
      src = pkgs.fetchurl {
        url = "https://github.com/Autonomy-Logic/openplc-editor/releases/download/v4.2.8/OpenPLC.Editor-4.2.8.AppImage";
        hash = "sha256-sUrViKFWPJDGVetSFDL+nLEDLQJxtQxF59j9BBLM8tc=";
      };
    })
  ];
}
