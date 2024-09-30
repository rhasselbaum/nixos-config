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
    (pkgs.writeShellScriptBin "snapclient-caprica" ''
      #usr/bin/env bash
      sleep 5  # avoid auddio setup race condition after login
      ${pkgs.snapcast}/bin/snapclient -h caprica -p 1704
    '')
    tmux
  ];
  nixpkgs.config.allowUnfree = true;

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
}
