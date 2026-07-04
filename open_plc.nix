{ config, pkgs, ... }:

{
  # ====================================================================
  # 1. OPENPLC RUNTIME (ΜΕΣΩ DOCKER)
  # ====================================================================
  virtualisation.oci-containers = {
    backend = "docker";
    containers.openplc-runtime = {
      image = "autonomylogic/openplc-runtime:latest";

      # Αντιστοίχιση της πόρτας 8443 του container με το PC σου
      ports = [ "8443:8443" ];

      # persistent volume για να μην χάνονται τα Ladder diagrams όταν κλείνει το container
      volumes = [
        "openplc-data:/var/lib/openplc"
      ];

      # Κρίσιμο: autoStart = false για να ΜΗΝ ξεκινάει μόνο του στο boot!
      autoStart = false;

      # 💡 Tip για ηλεκτρολόγους: Αν ποτέ συνδέσεις physical PLC ή Modbus μέσω USB (π.χ. RS485),
      # ξεσχολίασε την παρακάτω γραμμή για να βλέπει το container τη θύρα σου:
      extraOptions = [ "--device=/dev/ttyUSB0" ];
    };
  };

  # ====================================================================
  # 2. OPENPLC EDITOR (APPIMAGE)
  # ====================================================================
  environment.systemPackages = with pkgs; [
    (pkgs.appimageTools.wrapType2 {
      name = "openplc-editor";
      src = pkgs.fetchurl {
        url = "https://github.com/thiagoralves/OpenPLC_Editor/releases/download/v1.0/OpenPLC_Editor_Linux.AppImage";
        hash = pkgs.lib.fakeHash; # Βάλε εδώ το hash που χρησιμοποιούσες και πριν
      };
    })
  ];
}
