# Plasma, Wayland, and NVIDIA, basically
{ config, lib, pkgs, ... }:
{
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    videoDrivers = [ "nvidia" ];
  };

  # NVIDIA setup. See https://nixos.wiki/wiki/Nvidia
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true;
    nvidiaSettings = true;
  };
  hardware.graphics.enable = true;

  # Plasma Wayland with SDDM
  services.desktopManager.plasma6.enable = true;
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
  qt = {
    enable = true;
  };

  # Enable GPU support in containers
  hardware.nvidia-container-toolkit.enable = true;

  # Pipewire for sound
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

}