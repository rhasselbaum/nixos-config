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
    signal-desktop
    zoom-us
    # backups
    duplicity
    gnupg
    inputs.duplicity-unattended.defaultPackage.x86_64-linux
    awscli2
    vlc
    gimp
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
  ];
  nixpkgs.config.allowUnfree = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Fish
  programs.fish.enable = true;
  programs.bash = {
    # Have bash interactive shells launch fish. See https://nixos.wiki/wiki/Fish.
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  # KDEConnect
  programs.kdeconnect.enable = true;

}