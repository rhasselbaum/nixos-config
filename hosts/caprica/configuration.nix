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
  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCiKBoPbtPBg6B950S/qLaun1Tm028cStkk+bQWKLXjq0O6gMpgSXl7kCLIA7NXpwM28zFZM/mfCnpNwuo3b5L6i4/YYDMLfItUWzXEfDaHrOJR7/8NeNX/2P02qs/4f+OwYz0NZrjJm9QqfH77h6Gx21swk3Fw80B1S7Ldwk4i1BksbuKlENB1XixVlmQ06xrXJ9MLwaI3MGzvp9kMq78L7RmbAkxh2yRub1nYyLxKRKOkzTlCdlpVWshBOC5bxkKTLDanNtRwMwjGHEXCKBvulokZ7Ax/pP7pEY1y8YywXOEvLvSv0bByCrflPnVTHdT64OSRrGoWUxlKKKeaN+xx robhas"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB3+j1wFgcmxlwh5IXyc8nPOrm9hciaKEDhQkzt5ERWS JuiceSSH"
    ];
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Local printer discovery.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
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
        "scorpia" = { id = "KDMF7EZ-S3Z5FQQ-WVB5VPV-73KK7LZ-3ZGELJ2-46CCPOE-WPWF5FJ-ORALOQY"; };
      };
      folders = {
        "Share" = {
          path = "${home-dir}/Share";
          id = "ama4k-hnmhd";
          devices = [ "iris" ];
        };
        "Commercial" = {
          path = "${home-dir}/Media/Commercial";
          id = "xhvo7-czpwr";
          devices = [ "iris" "scorpia" ];
        };
        "Photos" = {
          path = "${home-dir}/Media/Photos";
          id = "ggjgv-w3jxr";
          devices = [ "iris" "scorpia" ];
        };
        "Videos" = {
          path = "${home-dir}/Media/Videos";
          id = "7c7kw-h9ktz";
          devices = [ "iris" "scorpia" ];
        };
      };
    };
  };

  # Sunshine
  services.sunshine = {
    enable = true;
    autoStart = false;
    capSysAdmin = true;
    openFirewall = true;
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

