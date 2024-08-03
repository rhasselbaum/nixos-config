{
  # Adapted from https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-with-flakes-enabled
  description = "Main Flake";

  inputs = {
    # NixOS official package source + Home Manager
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Disko
    disko.url = "github:nix-community/disko";

    # Common home env repo, used for non-Nix, too.
    common-homeenv = {
      url = "github:rhasselbaum/homeenv";
      flake = false;
    };

    # Flake for defining libvirt domains and networks
    nixvirt.url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
    nixvirt.inputs.nixpkgs.follows = "nixpkgs";

    # Other local pkgs
    duplicity-unattended.url = "path:pkgs/duplicity-unattended";
    duplicity-unattended.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, common-homeenv, duplicity-unattended, nixvirt, ... }@inputs:
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
        ({ config, lib, ... }: import ./hosts/caprica/configuration.nix {
          inherit config lib pkgs inputs;
        })
        nixvirt.nixosModules.default # Make NixVirt options available to other modules
        ./hosts/caprica/network-and-virt.nix
        ./modules/plasma-nvidia.nix
        ./hosts/caprica/system-packages.nix

	      # Home Manager
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.rob.imports = [
            ({ config, ... }: import ./hosts/caprica/home.nix {
              inherit config pkgs inputs;
            })
          ];
        }

        # Set all inputs parameters as special arguments for all submodules,
        # so we can directly use all dependencies in inputs in submodules.
        # See https://shorturl.at/XiEdG
        {
          _module.args = { inherit inputs; };
        }
      ];
    };
  };
}
