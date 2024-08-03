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
  hardware.nvidia-container-toolkit.enable = config.virtualisation.containers.enable;

  # Pipewire for sound
  security.rtkit.enable = true; # Used to acquire realtime priority if needed
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

}