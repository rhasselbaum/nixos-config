# Shared Snapcast client configs
{ config, pkgs, inputs, ... }:
let
  common-homeenv = inputs.common-homeenv;
  home-dir = "/home/rob";
in
{
  # User systemd units
  systemd.user = {
    services.snapcast-caprica = {
      Unit = {
        Description = "Snapcast client of Caprica";
        Requires = [ "pipewire.service" ];
        After = [ "pipewire.service" ];
      };
      Service = {
        Type = "exec";
        Restart = "no";
        ExecStart = ''
          ${pkgs.coreutils}/bin/timeout --preserve-status 250m \
            ${pkgs.snapcast}/bin/snapclient -h caprica -p 1704
        '';
      };
    };
  };

}
