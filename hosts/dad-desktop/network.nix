# Network and virtualization for personal PC
{ config, lib, pkgs, inputs, ... }:
let
  wireguard_dev = "wg0";
  home-dir = "/home/rob";
in
{
  # Pick only one of the below networking options.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  # Don't try to manage wireguard.
  networking.networkmanager.unmanaged = [ wireguard_dev ];

  # Wireguard for VPN to Caprica.
  networking.wireguard.interfaces."${wireguard_dev}" =
  let
    publicKey = "m4L3U4/TLceIjAq7BKqKh1GGzHjF0OWOPaGFdELUx1M=";
  in
  {
    ips = [ "192.168.124.2/24" ];
    listenPort = 3955; # to match firewall allowedUDPPorts (without this wg uses random port numbers)

    privateKeyFile = "${home-dir}/.wireguard/private.key";
    postSetup = ["wg set ${wireguard_dev} peer ${publicKey} persistent-keepalive 25"];
    peers = [
      {
        inherit publicKey;

        # Caprica
        allowedIPs = [ "192.168.124.1/32" ];

        # Server public IP and port.
        endpoint = "heritage.dyn.hasselbaum.net:3955";

        # Use postSetup instead of this setting because otherwise it doesn't auto
        # connect to the peer when using a private key file. See https://wiki.nixos.org/wiki/WireGuard
        #persistentKeepalive = 25;
      }
    ];
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22    # SSH
    22000 # Syncthing
    # 3389  # Plasma remote desktop -- or use SSH tunnel
   ];
  networking.firewall.allowedUDPPorts = [
    22000 # Syncthing
    21027 # Syncthing (discovery)
    3955  # Wireguard
   ];
}

