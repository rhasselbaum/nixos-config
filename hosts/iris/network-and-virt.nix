# Network and virtualization for personal PC
{ config, lib, pkgs, inputs, ... }:

{
  # Pick only one of the below networking options.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22    # SSH
    22000 # Syncthing
   ];
  networking.firewall.allowedUDPPorts = [
    22000 # Syncthing
    21027 # Syncthing (discovery)
   ];
}

