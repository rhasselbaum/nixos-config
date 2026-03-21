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
    host-tools.url = "github:rhasselbaum/host-tools";
    host-tools.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nixvirt, ... }@inputs:
  let
    # Rob's primary SSH public key, used to grant access across all hosts.
    robSshKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVklqPIhhFfoGuTU6hnur2sT8RHUZ5i4KZhmgevBl8Tzc/hcrDYUjylS2LCJbWeMyhldCDjgLjqIAj+X/azYHqT1sRa+xRfx50Q76FX3OxWsmGiYk/u/JRbBw226FpB474gjQkSXPGyjSM4gJB9wfc2nWj8riTa4cPuImMACdDoqFNxIiVWX+nJ9d+YWztOja6spFnP/KoFblfmPvm4tjS6R6OlajRhveeZSmiRrq/GbkOD8HbeXffGltVF8CSf1C1SIuCYZ+p4h7xkYbPyVGQyXfuLDLusWr0+H+1j7uhUT4XCwg3lQCScyGDhhwlTQRwFd7/MxqvED4Q03+I9zqtMeZ6mOHo1/LrncBEJcMVqSfC5tFS4nhvwo6IjhS7TzLkvh5CwAN3/63rNXSivFrfItPWOfE3mkOI7iNFacJqbXNdht+R3jaWYGUh6uCzmn/0YwJ7yuvm1I3Tbpf6A57TJX7RAHI0pU+F81m58xsmHNJQm9QSbPs6W8OPZadkD/Id8JZPkEy7ktdfOy1TzDVZMnGC+JkumYkB2yFF36xu909vPtLZ/Ncu7ffCcPpx9GCsP6KKpWqNTrD4teNta6jn2VKREuxz3Vk5nfJRp8WgBBla/1kUse8tw3LykMiQS6f8uFGb7459dBeDFnbg6ifM9TtYVW31PiKpJgf5z2pWUw== rob@caprica";
  in
  {
    nixosConfigurations.caprica = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs robSshKey; };
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
      specialArgs = { inherit inputs robSshKey; };
      modules = [

        # Machine config
        ./modules/configuration-minimal.nix
        ./hosts/amethyst/configuration.nix
        ./hosts/amethyst/network.nix
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
      specialArgs = { inherit inputs robSshKey; };
      modules = [

        # Machine config
        ./modules/configuration-minimal.nix
        ./modules/configuration-pi4-speaker.nix
        ./hosts/aquaria/configuration.nix
        ./modules/system-packages-pi4-speaker.nix

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

    nixosConfigurations.picon = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs robSshKey; };
      modules = [

        # Machine config
        ./modules/configuration-minimal.nix
        ./modules/configuration-pi4-speaker.nix
        ./hosts/picon/configuration.nix
        ./modules/system-packages-pi4-speaker.nix

        # Home Manager
        home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.rob.imports = [
            ./modules/home-rob-minimal.nix
            ./modules/home-rob-snapcast-client.nix
            ./hosts/picon/home-rob-extended.nix
            ./modules/home-rob-mqtt-launcher.nix
          ];
        }
      ];
    };

    nixosConfigurations.scorpia = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs robSshKey; };
      modules = [

        nixvirt.nixosModules.default # Make NixVirt options available to other modules

	      # Machine config
        ./modules/configuration-minimal.nix
        ./hosts/scorpia/configuration.nix
        ./hosts/scorpia/network-and-virt.nix
        ./modules/plasma-base.nix
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
      specialArgs = { inherit inputs robSshKey; };
      modules = [

        # Machine config
        ./modules/configuration-minimal.nix
        ./hosts/dad-desktop/configuration.nix
        ./hosts/dad-desktop/network.nix
        ./modules/plasma-base.nix
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

    nixosConfigurations.dad-laptop = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs robSshKey; };
      modules = [

        # Machine config
        ./modules/configuration-minimal.nix
        ./hosts/dad-laptop/configuration.nix
        ./hosts/dad-laptop/network.nix
        ./modules/plasma-base.nix
        ./hosts/dad-laptop/system-packages.nix

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
