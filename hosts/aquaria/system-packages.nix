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