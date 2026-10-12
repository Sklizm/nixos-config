{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    umbriel.url = "github:noctalia-dev/umbriel";
    noctalia.url = "github:noctalia-dev/noctalia";
  };

  outputs = { nixpkgs, umbriel, noctalia, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        umbriel.nixosModules.default
        noctalia.nixosModules.default
      ];
    };
  };
}
