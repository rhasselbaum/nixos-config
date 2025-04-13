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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" "openrazer" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCiKBoPbtPBg6B950S/qLaun1Tm028cStkk+bQWKLXjq0O6gMpgSXl7kCLIA7NXpwM28zFZM/mfCnpNwuo3b5L6i4/YYDMLfItUWzXEfDaHrOJR7/8NeNX/2P02qs/4f+OwYz0NZrjJm9QqfH77h6Gx21swk3Fw80B1S7Ldwk4i1BksbuKlENB1XixVlmQ06xrXJ9MLwaI3MGzvp9kMq78L7RmbAkxh2yRub1nYyLxKRKOkzTlCdlpVWshBOC5bxkKTLDanNtRwMwjGHEXCKBvulokZ7Ax/pP7pEY1y8YywXOEvLvSv0bByCrflPnVTHdT64OSRrGoWUxlKKKeaN+xx robhas"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB3+j1wFgcmxlwh5IXyc8nPOrm9hciaKEDhQkzt5ERWS JuiceSSH"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMSiqnK63GY16iC+FhRseDksjdfOXx20lUECYdXzUjq rob@scorpia"
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

  # Razer keyboard
  hardware.openrazer.enable = true;

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
        "scorpia" = { id = "LFPMCYX-7BA2OH5-3TCQF2S-Y3M4YUK-VVRY453-Q3R7POC-NQGKUTG-JAGYVQG"; };
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

  # Snapcast
  services.snapserver = {
    enable = true;
    buffer = 2000;
    openFirewall = true;
    codec = "flac";
    streams = {
      dispatch  = {
        type = "pipe";
        location = "/run/snapserver/dispatch";
      };
    };
  };

  # Snapcast pipe sink for Pipewire
  services.pipewire.extraConfig.pipewire = {
    "60-snapcast-sink" = {
      "context.modules" = [
        {
          name = "libpipewire-module-pipe-tunnel";
          args = {
              "node.name" = "Snapcast";
              "tunnel.mode" = "sink";
              "pipe.filename" = "/run/snapserver/dispatch";
              "audio.format" = "S16LE";
              "audio.rate" = 48000;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
          };
        }
      ];
    };
  };

  # Sunshine
  services.sunshine = {
    enable = true;
    autoStart = false;
    capSysAdmin = true;
    openFirewall = true;
  };

  # Auto login to Plasma
  services.displayManager = {
	  autoLogin.enable = true;
	  autoLogin.user = username;
  };

}

