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
      type = types.str;
      description = ''
        Sound device for output.
      '';
    };
    latency = mkOption {
      default = 0;
      type = types.int;
      description = ''
        Device latency in milliseconds.
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
              ${pkgs.snapcast}/bin/snapclient -h caprica.hasselbaum.net -p 1704${if cfg.soundcard != "" then " -s ${cfg.soundcard}" else ""}${if cfg.latency != 0 then " --latency ${builtins.toString cfg.latency}" else ""}
          '';
        };
      };
    };
  };
}
