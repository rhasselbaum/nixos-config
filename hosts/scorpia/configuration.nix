# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# Caprica config
{ config, lib, pkgs, inputs, ... }:
let
  home-dir = "/home/rob";
  username = "rob";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      "${inputs.disko}/module.nix"
      ./disk-config.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hello, my name is...
  networking.hostName = "scorpia";

  # Enable Flakes support
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ];
    openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVklqPIhhFfoGuTU6hnur2sT8RHUZ5i4KZhmgevBl8Tzc/hcrDYUjylS2LCJbWeMyhldCDjgLjqIAj+X/azYHqT1sRa+xRfx50Q76FX3OxWsmGiYk/u/JRbBw226FpB474gjQkSXPGyjSM4gJB9wfc2nWj8riTa4cPuImMACdDoqFNxIiVWX+nJ9d+YWztOja6spFnP/KoFblfmPvm4tjS6R6OlajRhveeZSmiRrq/GbkOD8HbeXffGltVF8CSf1C1SIuCYZ+p4h7xkYbPyVGQyXfuLDLusWr0+H+1j7uhUT4XCwg3lQCScyGDhhwlTQRwFd7/MxqvED4Q03+I9zqtMeZ6mOHo1/LrncBEJcMVqSfC5tFS4nhvwo6IjhS7TzLkvh5CwAN3/63rNXSivFrfItPWOfE3mkOI7iNFacJqbXNdht+R3jaWYGUh6uCzmn/0YwJ7yuvm1I3Tbpf6A57TJX7RAHI0pU+F81m58xsmHNJQm9QSbPs6W8OPZadkD/Id8JZPkEy7ktdfOy1TzDVZMnGC+JkumYkB2yFF36xu909vPtLZ/Ncu7ffCcPpx9GCsP6KKpWqNTrD4teNta6jn2VKREuxz3Vk5nfJRp8WgBBla/1kUse8tw3LykMiQS6f8uFGb7459dBeDFnbg6ifM9TtYVW31PiKpJgf5z2pWUw== rob@caprica"
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AllowUsers = [username];
      PermitRootLogin = "no";
    };
  };

  # Syncthing
  services.syncthing = {
    enable = true;
    user = username;
    group = "users";
    dataDir = "${home-dir}/Share";
    configDir = "${home-dir}/.config/syncthing";
    overrideDevices = true;     # overrides any devices added or deleted through the WebUI
    overrideFolders = true;     # overrides any folders added or deleted through the WebUI
    settings = {
      devices = {
        "iris" = { id = "VQ2GDTP-R4RSCSB-YVIOX5S-2NIBS76-GJ4G2UJ-DY2XSK3-EKR55K5-V6EDQAZ"; };
        "caprica" = { id = "HAINGKT-RK4NGP4-H4QXJ3O-X6UQRGE-IKOV6SH-R7BYHLM-W6UHWET-ORQOJAM"; };
      };
      folders = {
        "Commercial" = {
          path = "${home-dir}/Media/Commercial";
          id = "xhvo7-czpwr";
          devices = [ "iris" "caprica" ];
        };
        "Photos" = {
          path = "${home-dir}/Media/Photos";
          id = "ggjgv-w3jxr";
          devices = [ "iris" "caprica" ];
        };
        "Videos" = {
          path = "${home-dir}/Media/Videos";
          id = "7c7kw-h9ktz";
          devices = [ "iris" "caprica" ];
        };
      };
    };
  };

  # Auto login to Plasma
  services.displayManager = {
	  autoLogin.enable = true;
	  autoLogin.user = username;
  };

  # Nix Store garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 60d";
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}
