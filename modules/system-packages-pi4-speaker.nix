{ config, lib, pkgs, inputs, ... }:
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    alsa-utils
    mplayer
    pulsemixer
    ffmpeg
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    snapcast
    tmux
    raspberrypi-eeprom
  ];
  nixpkgs.config.allowUnfree = true;

}
