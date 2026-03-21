# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# Common config for Raspberry Pi 4 speakers
{ config, lib, pkgs, inputs, robSshKey, ... }:
let
  home-dir = "/home/rob";
  username = "rob";
in
{

  # Use the extlinux boot loader for Raspberry Pi
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # Basic networking
  networking.networkmanager.enable = true;
  # Powersasve causes host to be unreachable on wifi after some time.
  networking.networkmanager.wifi.powersave = false;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22    # SSH
  ];

  # Enable audio devices
  boot.kernelParams = [ "snd_bcm2835.enable_hdmi=0" "snd_bcm2835.enable_headphones=1" ];

  # Pipewire for sound
  security.rtkit.enable = true; # Used to acquire realtime priority if needed
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    socketActivation = false; # too slow for headless; start at boot instead
  };

  # Start WirePlumber (with PipeWire) at boot.
  systemd.user.services.wireplumber.wantedBy = [ "default.target" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    linger = true; # for headless audio at least
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" ];
    openssh.authorizedKeys.keys = [
      robSshKey
    ];
  };

  # MPD
  services.mpd = {
    user = username;
    enable = true;
    settings = {
      audio_output = [
        {
          type = "pipewire";
          name = "Pipewire Output";
        }
      ];
      bind_to_address =  "any"; # Bind to all interfaces (default port 6600)
      music_directory = "${home-dir}/Music";
    };
    startWhenNeeded = true; # Only start when socket is connected
    openFirewall = true;
  };

  # Special MPD config to use the Pipewire session owned by ${username}.
  # Their UID isn't known until runtime so need a preStart script to generate
  # the environment file.
  systemd.services.mpd = {
    # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
    preStart = ''
      ${pkgs.writeShellScript "gen-env.sh" ''
        echo XDG_RUNTIME_DIR="/run/user/$(id -u ${username})" > $1
      ''} /run/mpd/mpd-service.env
    '';
    serviceConfig.EnvironmentFile = "-/run/mpd/mpd-service.env";
  };

}

