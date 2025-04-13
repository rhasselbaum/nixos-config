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
    # Weird Vivaldi stuff needed for Plasma Wayland. See https://github.com/NixOS/nixpkgs/pull/292148
    # Also, go to vivaldi://flags and set Ozone to Wayland. See https://discuss.kde.org/t/plasma-6-and-screen-flickering-in-vivaldi/10999
    (vivaldi.overrideAttrs (oldAttrs: {
      dontWrapQtApps = false;
      dontPatchELF = true;
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.kdePackages.wrapQtAppsHook ];
    }))
    qt5.qtwayland # Needed for Vivaldi at least
    qemu
    vlc
    pavucontrol
    helvum
  ];
  nixpkgs.config.allowUnfree = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = false; # Open ports in the firewall for Steam Local Network Game Transfers
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };

}