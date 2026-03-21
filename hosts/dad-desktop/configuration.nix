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
  networking.hostName = "dad-desktop";

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

  # Flatpak
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # Auto-update Flatpak apps periodically
  systemd.services.flatpak-updates = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = "flatpak update -y";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
  systemd.timers.flatpak-updates = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
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
        "dell-laptop" = { id = "2R6FDQE-OFOXWQC-PO7BO4W-6TGFCU6-6UQTQAU-2DFIIQU-UUCTEGP-XCILIQP"; };
        "dad-laptop" = { id = "H6QOK27-A2DTS55-BLKLMWJ-7244YEE-JR52KVD-SSP2DLK-APRERSA-QCGRSAO"; };
      };
      folders = {
        "Documents" = {
          path = "${home-dir}/Documents";
          id = "ywowf-3v9uc";
          devices = [ "dell-laptop" "dad-laptop" ];
        };
        "Downloads" = {
          path = "${home-dir}/Downloads";
          id = "zjfrj-jxtqq";
          devices = [ "dell-laptop" "dad-laptop" ];
        };
      };
    };
  };

}

