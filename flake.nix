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

    # Other pkgs
    duplicity-unattended.url = "github:rhasselbaum/duplicity-unattended/flake";
    duplicity-unattended.inputs.nixpkgs.follows = "nixpkgs";
    mqtt-launcher.url = "github:rhasselbaum/mqtt-launcher/flake";
    mqtt-launcher.inputs.nixpkgs.follows = "nixpkgs";
    polychromatic-tools.url = "github:rhasselbaum/polychromatic-tools";
    polychromatic-tools.inputs.nixpkgs.follows = "nixpkgs";
    snapcast-tools.url = "github:rhasselbaum/snapcast-tools";
    snapcast-tools.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nixvirt, ... }@inputs:
  {
    nixosConfigurations.caprica = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [

        nixvirt.nixosModules.default # Make NixVirt options available to other modules

	      # Machine config
        ./modules/configuration-minimal.nix
        ./hosts/caprica/configuration.nix
        ./hosts/caprica/network-and-virt.nix
        ./modules/plasma-nvidia.nix
        ./hosts/caprica/system-packages.nix

	      # Home Manager
        home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.rob.imports = [
            ./modules/home-rob-minimal.nix
            ./modules/home-rob-snapcast-client.nix
            ./hosts/caprica/home-rob-extended.nix
            ./modules/home-rob-mqtt-launcher.nix
          ];
        }
      ];
    };

    nixosConfigurations.amethyst = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [

        # Machine config
        ./modules/configuration-minimal.nix
        ./hosts/amethyst/configuration.nix
        ./hosts/amethyst/network-and-virt.nix
        ./modules/plasma-nvidia.nix
        ./hosts/amethyst/system-packages.nix

        # Home Manager
        home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.rob.imports = [
            ./modules/home-rob-minimal.nix
          ];
          home-manager.users.amy.imports = [
            ./hosts/amethyst/home-amy.nix
          ];
        }
      ];
    };

    nixosConfigurations.aquaria = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [

        # Machine config
        ./modules/configuration-minimal.nix
        ./hosts/aquaria/configuration.nix
        ./hosts/aquaria/system-packages.nix

        # Home Manager
        home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.rob.imports = [
            ./modules/home-rob-minimal.nix
            ./modules/home-rob-snapcast-client.nix
            ./hosts/aquaria/home-rob-extended.nix
            ./modules/home-rob-mqtt-launcher.nix
          ];
        }
      ];
    };

    nixosConfigurations.scorpia = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [

        nixvirt.nixosModules.default # Make NixVirt options available to other modules

	      # Machine config
        ./modules/configuration-minimal.nix
        ./hosts/scorpia/configuration.nix
        ./hosts/scorpia/network-and-virt.nix
        ./modules/plasma-kerneldrv.nix
        ./hosts/scorpia/system-packages.nix

	      # Home Manager
        home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.rob.imports = [
            ./modules/home-rob-minimal.nix
            ./modules/home-rob-snapcast-client.nix
            ./modules/home-rob-mqtt-launcher.nix
            ./hosts/scorpia/home-rob-extended.nix
          ];
        }
      ];
    };

    nixosConfigurations.dad-desktop = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [

        # Machine config
        ./modules/configuration-minimal.nix
        ./hosts/dad-desktop/configuration.nix
        ./hosts/dad-desktop/network-and-virt.nix
        ./modules/plasma-kerneldrv.nix
        ./hosts/dad-desktop/system-packages.nix

        # Home Manager
        home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.rob.imports = [
            ./modules/home-rob-minimal.nix
          ];
        }
      ];
    };
  };
}
