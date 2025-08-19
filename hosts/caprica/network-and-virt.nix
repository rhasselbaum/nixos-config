# Network and virtualization for personal PC
{ config, lib, pkgs, inputs, ... }:

let
  libvirt_nat_bridge_dev = "virbr0";
  libvirt_sandbox_dev = "sandbox0";
  parents_wireguard_dev = "wg0";
  nixvirt = inputs.nixvirt;
  home-dir = "/home/rob";
in
{
  # Pick only one of the below networking options.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  # Don't try to manage the libvirt bridges or wireguard.
  networking.networkmanager.unmanaged = [ libvirt_nat_bridge_dev libvirt_sandbox_dev parents_wireguard_dev ];

  # Podman
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Libvirt + QEMU + KVM with NixVirt
  virtualisation.libvirt = {
    enable = true;
    connections."qemu:///system" = {
      networks = [
        {
          definition = nixvirt.lib.network.writeXML (nixvirt.lib.network.templates.bridge {
            name = "default";
            uuid = "cda3b7dd-71fd-44e3-8093-340f47a88c83";
            subnet_byte = 122;
            bridge_name = libvirt_nat_bridge_dev;
          });
          active = true;
        }
        {
          definition = nixvirt.lib.network.writeXML {
            name = "sandbox";
            uuid = "703c2b85-da03-4e42-84d7-c57663ea14e7";
            bridge.name = libvirt_sandbox_dev;
            ip = {
              address = "192.168.123.1";
              netmask = "255.255.255.0";
              dhcp.range = { start = "192.168.123.2"; end = "192.168.123.254"; };
            };
          };
          active = true;
        }
      ];
    };
  };

  virtualisation.libvirtd = {
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true; # Doesn't actually run as root because of overriding config below.
      # We want to run as a specific user/group, not Nix's non-root default of `qemu-libvirtd`,
      verbatimConfig =
      ''
        namespaces = []
        user = "rob"
        group = "users"
      '';
    };
  };
  programs.virt-manager.enable = true;

  # Wireguard for VPN to Mom & Dad's place.
  networking.wireguard.interfaces."${parents_wireguard_dev}" = {
    ips = [ "192.168.124.1/24" ];
    listenPort = 3955;
    privateKeyFile = "${home-dir}/.wireguard/private.key";
    peers = [
      {
        # Dad's desktop
        publicKey = "mqCIXjMQMYJUXIvKGQxlfXOajIvXDKnRsd1REIvQS3U=";
        allowedIPs = [ "192.168.124.2/32" ];
      }
      {
        # Dad's laptop
        publicKey = "ykQuzCTGXNOFv2Nif7zNSA8rhNlNnZE3HPn376Ywfz8=";
        allowedIPs = [ "192.168.124.3/32" ];
      }
    ];
  };

  # Open ports in the firewall.
  networking.firewall.trustedInterfaces = [ libvirt_sandbox_dev libvirt_nat_bridge_dev ]; # Allow traffic on the container sandbox bridge.
  networking.firewall.allowedTCPPorts = [
    22    # SSH
    22000 # Syncthing
   ];
  networking.firewall.allowedUDPPorts = [
    22000 # Syncthing
    21027 # Syncthing (discovery)
    3955  # Wireguard
   ];

  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # TODO: Generate containers-host-only Podman bridge config via Nix.
  # TODO: Validate that my user is part of libvirtd group.

}

