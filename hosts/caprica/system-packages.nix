{ config, lib, pkgs, inputs, ... }:
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    # Weird Vivaldi stuff needed for Plasma Wayland. See https://github.com/NixOS/nixpkgs/pull/292148 and wiki.
    # Also, go to vivaldi://flags and set Ozone to Wayland. See https://discuss.kde.org/t/plasma-6-and-screen-flickering-in-vivaldi/10999
    # If that doesn't solve flickering, try toggling "Use Hardware Acceleration When Available". See https://discourse.nixos.org/t/flickering-vivaldi-7-5-on-plasma-wayland-with-nvidia
    (vivaldi.overrideAttrs (oldAttrs: {
      dontWrapQtApps = false;
      dontPatchELF = true;
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.kdePackages.wrapQtAppsHook ];
    }))
    firefox
    qt5.qtwayland # Needed for Vivaldi at least
    qemu
    (python3.withPackages (p: with p; [ black ]))
    buildah
    passt # Network support for buildah
    signal-desktop
    vscode
    zoom-us
    duplicity
    gnupg
    inputs.duplicity-unattended.defaultPackage.x86_64-linux
    awscli2
    aws-sam-cli
    vlc
    gimp
    pavucontrol
    helvum
    ffmpeg
    snapcast
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    jq
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
    wireguard-tools
    kdePackages.krdc
    yt-dlp
    mplayer
    kdePackages.kdenlive
    nmap
    openrazer-daemon
    polychromatic
  ];
  nixpkgs.config.allowUnfree = true;

  # Needed for VS Code under Wayland. See https://nixos.wiki/wiki/Visual_Studio_Code
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };

  # KDEConnect
  programs.kdeconnect.enable = true;

}