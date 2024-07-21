# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# Caprica config
{ config, lib, pkgs, ... }:

let
  disko_module = builtins.fetchGit {
    url = https://github.com/nix-community/disko.git;
    rev = "786965e1b1ed3fd2018d78399984f461e2a44689";
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      "${disko_module}/module.nix"
      ./disk-config.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hello, my name is...
  networking.hostName = "caprica";
 
  # Enable Flakes support
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rob = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ];
    packages = with pkgs; [
    ];
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services.syncthing = {
    enable = true;
    user = "rob";
    group = "users";
    dataDir = "/home/rob/Share";
    configDir = "/home/rob/.config/syncthing";
    overrideDevices = true;     # overrides any devices added or deleted through the WebUI
    overrideFolders = true;     # overrides any folders added or deleted through the WebUI
    settings = {
      devices = {
        "iris" = { id = "BKAPMSL-SQLG2YT-XKF4LQZ-SJE66PS-CXDN3FX-YMU2UEJ-XU4JFJY-7JNPTAL"; };
        "scorpia" = { id = "KDMF7EZ-S3Z5FQQ-WVB5VPV-73KK7LZ-3ZGELJ2-46CCPOE-WPWF5FJ-ORALOQY"; };
      };
      folders = {
        "Share" = {         # Name of folder in Syncthing, also the folder ID
          path = "/home/rob/Share";
          id = "ama4k-hnmhd";
          devices = [ "iris" ];
        };
        "Commercial" = {
          path = "/home/rob/Media/Commercial";
          id = "xhvo7-czpwr";
          devices = [ "iris" "scorpia" ];
        };
        "Photos" = {
          path = "/home/rob/Media/Photos";
          id = "ggjgv-w3jxr";
          devices = [ "iris" "scorpia" ];
        };
        "Videos" = {
          path = "/home/rob/Media/Videos";
          id = "7c7kw-h9ktz";
          devices = [ "iris" "scorpia" ];
        };
      };
    };
  };


  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

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

