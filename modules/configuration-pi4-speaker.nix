# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# Common config for Raspberry Pi 4 speakers
{ config, lib, pkgs, inputs, ... }:
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
    6600  # MPD
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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVklqPIhhFfoGuTU6hnur2sT8RHUZ5i4KZhmgevBl8Tzc/hcrDYUjylS2LCJbWeMyhldCDjgLjqIAj+X/azYHqT1sRa+xRfx50Q76FX3OxWsmGiYk/u/JRbBw226FpB474gjQkSXPGyjSM4gJB9wfc2nWj8riTa4cPuImMACdDoqFNxIiVWX+nJ9d+YWztOja6spFnP/KoFblfmPvm4tjS6R6OlajRhveeZSmiRrq/GbkOD8HbeXffGltVF8CSf1C1SIuCYZ+p4h7xkYbPyVGQyXfuLDLusWr0+H+1j7uhUT4XCwg3lQCScyGDhhwlTQRwFd7/MxqvED4Q03+I9zqtMeZ6mOHo1/LrncBEJcMVqSfC5tFS4nhvwo6IjhS7TzLkvh5CwAN3/63rNXSivFrfItPWOfE3mkOI7iNFacJqbXNdht+R3jaWYGUh6uCzmn/0YwJ7yuvm1I3Tbpf6A57TJX7RAHI0pU+F81m58xsmHNJQm9QSbPs6W8OPZadkD/Id8JZPkEy7ktdfOy1TzDVZMnGC+JkumYkB2yFF36xu909vPtLZ/Ncu7ffCcPpx9GCsP6KKpWqNTrD4teNta6jn2VKREuxz3Vk5nfJRp8WgBBla/1kUse8tw3LykMiQS6f8uFGb7459dBeDFnbg6ifM9TtYVW31PiKpJgf5z2pWUw== rob@caprica"
    ];
  };

  # MPD
  services.mpd = {
    user = username;
    enable = true;
    musicDirectory = "${home-dir}/Music";
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "Pipewire Output"
      }
    '';
    network.listenAddress = "any"; # Bind to all interfaces (default port 6600)
    startWhenNeeded = true; # Only start when socket is connected
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

}

