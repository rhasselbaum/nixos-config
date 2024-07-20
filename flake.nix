{
  # Adapted from https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-with-flakes-enabled
  description = "Main Flake";

  inputs = {
    # NixOS official package source + Home Manager
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Common home env repo, used for non-Nix, too.
    common-homeenv = {
      url = "github:rhasselbaum/homeenv";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, common-homeenv, ... }@inputs: 
  let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true; 
    };
  in
  {
    nixosConfigurations.caprica = nixpkgs.lib.nixosSystem {
      modules = [
	      # Machine config
        ./hosts/caprica/configuration.nix
        ./hosts/caprica/network-and-virt.nix
        ./hosts/caprica/graphics-and-sound.nix
        ./hosts/caprica/system-packages.nix

	      # Home Manager
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.rob.imports = [ 
            ({ config, ... }: import ./hosts/caprica/home.nix {
              inherit config pkgs common-homeenv;
            })
          ];
        }
      ];
    };
  };
}
