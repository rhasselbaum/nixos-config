# Shared Snapcast client configs
{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.programs.snapcast-caprica;
in
{
  options.programs.snapcast-caprica = {
    enable = mkEnableOption "Snapcast Caprica client";
    soundcard = mkOption {
      default = "";
      type = types.string;
      description = ''
        Sound device for output.
      '';
    };
  };

  config = mkIf cfg.enable {
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
              ${pkgs.snapcast}/bin/snapclient -h caprica -p 1704${if cfg.soundcard != "" then " -s ${cfg.soundcard}" else ""}
          '';
        };
      };
    };
  };
}
