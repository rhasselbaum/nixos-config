# Network and virtualization for personal PC
{ config, lib, pkgs, ... }:

let
  libvirt_nat_bridge_dev = "virbr0";
  libvirt_sandbox_dev = "sandbox0";
in
{
  # Pick only one of the below networking options.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  # Don't try to manage the libvirt bridges.
  networking.networkmanager.unmanaged = [ libvirt_nat_bridge_dev libvirt_sandbox_dev ];

  # Podman
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Libvirt + QEMU + KVM
  virtualisation.libvirtd = {
    enable = true;
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

  # Open ports in the firewall.
  networking.firewall.trustedInterfaces = [ libvirt_sandbox_dev ]; # Allow traffic on the container sandbox bridge.
  networking.firewall.allowedTCPPorts = [
    22000 # Syncthing

   ];
  networking.firewall.allowedUDPPorts = [
    22000 # Syncthing
    21027 # Syncthing (discovery)
   ];

  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # TODO: Generate libvirt bridge configs via Nix.
  # TODO: Generate containers-host-only Podman bridge config via Nix.
  # TODO: Validate that my user is part of libvirtd group.

}

