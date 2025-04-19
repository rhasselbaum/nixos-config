{ config, lib, pkgs, inputs, ... }:
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    firefox
    google-chrome
    qt5.qtwayland # Needed for Vivaldi at least
    signal-desktop-source
    zoom-us
    duplicity
    gnupg
    inputs.duplicity-unattended.defaultPackage.x86_64-linux
    awscli2
    vlc
    gimp
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
    pavucontrol
  ];
  nixpkgs.config.allowUnfree = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # KDEConnect
  programs.kdeconnect.enable = true;

}