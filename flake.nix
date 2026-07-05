{
  description = "Η κεντρική Flake παραμετροποίηση του συστήματος";

  inputs = {
    # Χρήση του ασταθούς/τελευταίου καναλιού (ιδανικό για την έκδοση 26.xx)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    hunk = {
          url = "github:modem-dev/hunk";
          inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = { inherit inputs; };

      modules = [ ./configuration.nix ];

    };
  };
}
