{ config, pkgs, ... }:

{
  environment.shellAliases = {
    "cls" = "clear";
    "del" = "rm -rf";

    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";

    cat = "bat";
    n = "superfile";

    ll = "eza -lh --icons";
    la = "eza -lah --icons";

    #Git commands
    lg = "lazygit";
    gi = "git init";
    gs = "git status";
    gpu = "git push";
    gpl = "git pull";

    #Tools
    diff = "hunk diff --mode split";
    api = "posting";
    ts = "tailscale status";

    #Nix commands
    nix-update = "sudo nixos-rebuild switch --flake /etc/nixos/#nixos --impure";
    nix-clean = "sudo nix-env --delete-generations old && sudo nix-store --gc";

    #OpenPLC Runtime Docker
    plc-start   = "sudo systemctl start docker-openplc-runtime.service";
    plc-stop    = "sudo systemctl stop docker-openplc-runtime.service";
    plc-status  = "sudo systemctl status docker-openplc-runtime.service";
  };

  environment.sessionVariables = {
    # Ορισμός του default editor για το τερματικό
    EDITOR = "zed";
    VISUAL = "zed";

    # Παράδειγμα: Αν έχεις scripts ή binaries στο home σου (~/.local/bin)
    # και θες το σύστημα να τα αναγνωρίζει από παντού ως εντολές:
    # PATH = [ "$HOME/.local/bin" ];
  };
}
