{ config, lib, pkgs, inputs, ... }:
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    google-chrome
    qt5.qtwayland # Needed for Vivaldi at least
    zoom-us
    vlc
    gimp
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
    pavucontrol
    flatpak
    gnome-software  # for Flatpak GUI installers
  ];
  nixpkgs.config.allowUnfree = true;

}