# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# Dad's desktop config
{ config, lib, pkgs, inputs, robSshKey, ... }:
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
      ../../modules/printing.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hello, my name is...
  networking.hostName = "dad-laptop";

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define user accounts.
  users.users = {
    rob = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        robSshKey
      ];
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Auto login to Plasma
  services.displayManager = {
	  autoLogin.enable = true;
	  autoLogin.user = username;
  };

  # Syncthing
  services.syncthing = {
    enable = true;
    user = "rob";
    group = "users";
    dataDir = "${home-dir}/Documents";
    configDir = "${home-dir}/.config/syncthing";
    overrideDevices = true;     # overrides any devices added or deleted through the WebUI
    overrideFolders = true;     # overrides any folders added or deleted through the WebUI
    settings = {
      devices = {
        "dad-desktop" = { id = "QM65LB4-HHSYEQM-IGLQEYQ-QHM7LK4-C4F2CWZ-HO6MAXH-L3L37NV-CNW46AX"; };
      };
      folders = {
        "Documents" = {
          path = "${home-dir}/Documents";
          id = "ywowf-3v9uc";
          devices = [ "dad-desktop" ];
        };
        "Downloads" = {
          path = "${home-dir}/Downloads";
          id = "zjfrj-jxtqq";
          devices = [ "dad-desktop" ];
        };
      };
    };
  };

}

