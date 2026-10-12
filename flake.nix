{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    umbriel.url = "github:noctalia-dev/umbriel";
    noctalia.url = "github:noctalia-dev/noctalia";
    home-manager = {
    	url = "github:nix-community/home-manager";
    	inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, umbriel, noctalia, home-manager, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        umbriel.nixosModules.default
        noctalia.nixosModules.default
        home-manager.nixosModules.home-manager
        {
        	home-manager.useGlobalPkgs = true;
        	home-manager.useUserPackages = true;
        	home-manager.users.codrin-nix = import ./home.nix;
        }
      ];
    };
  };
}
