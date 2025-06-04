# Network and virtualization for personal PC
{ config, lib, pkgs, inputs, ... }:

let
  nixvirt = inputs.nixvirt;
  bridge_dev = "br0";
  eth_dev = "enp0s25";
in
{
  # Configure bridged networking for Home Assistant VM + physical Ethernet. We use
  # systemd-networkd instead of the usual NetworkManager because the latter was leading
  # to IP address conflicts even though all applicable interfaces were set as unmanaged.
  # ¯\_(ツ)_/¯
  # Adapted from https://github.com/NixOS/nixpkgs/issues/355450#issuecomment-2470860172
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    netdevs = {
      "30-${bridge_dev}" = {
        netdevConfig = {
          Kind = "bridge";
          Name = bridge_dev;
          MACAddress = "none";
        };
      };
    };
    networks = {
      # Define only the bridge and Physical NIC. libvirtd should add its NIC to the bridge.
      "30-${eth_dev}" = {
        name = eth_dev;
        bridge = [ bridge_dev ];
      };
      "30-${bridge_dev}" = {
        name = bridge_dev;
        DHCP = "yes";
      };
    };
    links = {
      "30-${bridge_dev}" = {
        matchConfig = {
          OriginalName = bridge_dev;
        };
        linkConfig = {
          MACAddressPolicy = "none";
        };
      };
    };
  };

  # Libvirt + QEMU + KVM with NixVirt
  virtualisation.libvirt = {
    enable = true;
    # Follow https://www.home-assistant.io/installation/linux for setup
  };
  virtualisation.libvirtd = {
    qemu = {
      package = pkgs.qemu_kvm;
      # Without this, "libvirt-guests" fails to autostart guests, giving a Spice socket error.
      # See https://www.reddit.com/r/archlinux/comments/n1ra5y/vm_always_fails_to_start_but_starts_if_tried/
      verbatimConfig = ''
        spice_listen = "::1"
      '';
    };
    onShutdown = "shutdown";
 };

  programs.virt-manager.enable = true;

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

