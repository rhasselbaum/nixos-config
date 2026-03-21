# Plasma, Wayland, and NVIDIA, basically
{ config, lib, pkgs, ... }:
{
  imports = [ ./plasma-base.nix ];

  # NVIDIA driver
  services.xserver.videoDrivers = [ "nvidia" ];

  # NVIDIA setup. See https://nixos.wiki/wiki/Nvidia
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true;
    nvidiaSettings = true;
  };

  # Enable GPU support in containers
  hardware.nvidia-container-toolkit.enable = config.virtualisation.containers.enable;

}
