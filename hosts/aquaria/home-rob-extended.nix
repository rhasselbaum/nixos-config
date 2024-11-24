# Home Manager config for rob
{ config, pkgs, inputs, ... }:
{
  programs.snapcast-caprica = {
    enable = true;
    soundcard = "Headphones";
  };
}
