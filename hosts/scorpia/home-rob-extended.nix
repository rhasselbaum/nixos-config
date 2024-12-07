# Home Manager config for rob
{ config, pkgs, ... }:
{
  programs.snapcast-caprica = {
    enable = true;
    latency = 210;
  };
}
