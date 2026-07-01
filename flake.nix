{
  description = "Η κεντρική Flake παραμετροποίηση του συστήματος";

  inputs = {
    # Χρήση του ασταθούς/τελευταίου καναλιού (ιδανικό για την έκδοση 26.xx)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
    };
  };
}
