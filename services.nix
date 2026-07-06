{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;

  services.tailscale.enable = true;
  services.fwupd.enable = true;

  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.sudo.fprintAuth = true;

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

  services.thermald.enable = true;

  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = true;
    };
  };

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

  services.tailscale = {
      enable = true;

      # If you would like to use a preauthorized key, set
      # authKeyFile = "/run/secrets/tailscale_key";
      # Note: maximum expire time is 90 days
    };
}
