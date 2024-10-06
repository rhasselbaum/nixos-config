# Plasma, Wayland, and Intel, basically
{ config, lib, pkgs, ... }:
{

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    videoDrivers = [ "intel" ];
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