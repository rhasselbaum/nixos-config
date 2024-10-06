# Network and virtualization for personal PC
{ config, lib, pkgs, inputs, ... }:

let
  nixvirt = inputs.nixvirt;
  libvirt_bridge_dev = "br0";
  eth_dev = "enp0s25";
in
{
  # Pick only one of the below networking options.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.networkmanager.unmanaged = [ libvirt_bridge_dev eth_dev ];

  # Libvirt + QEMU + KVM with NixVirt
  virtualisation.libvirt = {
    enable = true;
    # Follow https://www.home-assistant.io/installation/linux for setup
  };
  virtualisation.libvirtd.qemu.package = pkgs.qemu_kvm;
  programs.virt-manager.enable = true;

  # Bridge for directly connecting VMs
  networking.interfaces."${libvirt_bridge_dev}".useDHCP = true;
  networking.interfaces."${eth_dev}".useDHCP = true;
  networking.bridges."${libvirt_bridge_dev}".interfaces = [ eth_dev ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22    # SSH
    22000 # Syncthing
   ];
  networking.firewall.allowedUDPPorts = [
    22000 # Syncthing
    21027 # Syncthing (discovery)
   ];

  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

}

