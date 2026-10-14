{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    umbriel.url = "github:noctalia-dev/umbriel";
    noctalia.url = "github:noctalia-dev/noctalia";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    home-manager = {
    	url = "github:nix-community/home-manager";
    	inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs = { nixpkgs, umbriel, noctalia, home-manager, nix-cachyos-kernel, zen-browser, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        umbriel.nixosModules.default
        noctalia.nixosModules.default
        home-manager.nixosModules.home-manager
        {
        	nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ];
        	home-manager.useGlobalPkgs = true;
        	home-manager.useUserPackages = true;
        	home-manager.users.codrin-nix = import ./home.nix;
        	home-manager.extraSpecialArgs = { inherit zen-browser; };
        }
      ];
    };
  };
}
