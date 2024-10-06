# Network and virtualization for personal PC
{ config, lib, pkgs, inputs, ... }:

let
  nixvirt = inputs.nixvirt;
in
{
  # Pick only one of the below networking options.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Libvirt + QEMU + KVM with NixVirt
  virtualisation.libvirt = {
    enable = true;
    connections."qemu:///system" = {
      domains = [
        {
          definition = ./libvirt/home-assistant-domain.xml;
          active = true;
        }
      ];
    };
  };

  virtualisation.libvirtd.qemu.package = pkgs.qemu_kvm;
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

  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

}

