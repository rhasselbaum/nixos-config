# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# Amethyst config
{ config, lib, pkgs, inputs, robSshKey, ... }:
let
  home-dir = "/home/amy";
  username = "amy";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      "${inputs.disko}/module.nix"
      ./disk-config.nix
      ../../modules/printing.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hello, my name is...
  networking.hostName = "amethyst";

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define user accounts.
  users.users = {
    amy = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
    rob = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        robSshKey
      ];
    };
  };

  # Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

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
        "caprica" = { id = "HAINGKT-RK4NGP4-H4QXJ3O-X6UQRGE-IKOV6SH-R7BYHLM-W6UHWET-ORQOJAM"; };
        "scorpia" = { id = "LFPMCYX-7BA2OH5-3TCQF2S-Y3M4YUK-VVRY453-Q3R7POC-NQGKUTG-JAGYVQG"; };
      };
      folders = {
        "Share" = {
          path = "${home-dir}/Share";
          id = "ama4k-hnmhd";
          devices = [ "caprica" ];
        };
        "Commercial" = {
          path = "${home-dir}/Media/Commercial";
          id = "xhvo7-czpwr";
          devices = [ "caprica" "scorpia" ];
        };
        "Photos" = {
          path = "${home-dir}/Media/Photos";
          id = "ggjgv-w3jxr";
          devices = [ "caprica" "scorpia" ];
        };
        "Videos" = {
          path = "${home-dir}/Media/Videos";
          id = "7c7kw-h9ktz";
          devices = [ "caprica" "scorpia" ];
        };
      };
    };
  };

  # Auto login to Plasma
  services.displayManager = {
	  autoLogin.enable = true;
	  autoLogin.user = username;
  };

}

