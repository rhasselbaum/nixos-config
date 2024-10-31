{ config, lib, pkgs, inputs, ... }:
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    # Weird Vivaldi stuff needed for Plasma Wayland. See https://github.com/NixOS/nixpkgs/pull/292148
    # Also, go to vivaldi://flags and set Ozone to Wayland. See https://discuss.kde.org/t/plasma-6-and-screen-flickering-in-vivaldi/10999
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
    jetbrains.pycharm-community
    wireguard-tools
    kdePackages.krdc
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