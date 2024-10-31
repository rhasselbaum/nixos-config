# Home Manager config for rob
{ config, pkgs, inputs, ... }:
let
  common-homeenv = inputs.common-homeenv;
  home-dir = "/home/rob";
in
{
  # Duplicity backups. On new systems, you need to create ~/.duplicity-unattended/aws_credentials and import your GPG key.
  # Obviously not including those here.
  home.file.".duplicity-unattended/config.yaml".text = ''
    ########################################################################
    # Config options for Duplicity host backup.
    ########################################################################

    # GnuPG key ID used for encryption and signing.
    gpg_key_id: 0302EC6D2613E4933D0DD66CB48526BB511A0E34

    # S3 bucket name and optional prefix in Duplicity URL format.
    bucket_url: s3:///caprica-backup

    # Create full backup if the last one is older than the specified period. Use Duplicity time format.
    full_if_older_than: 1M

    # Purge old backups, retaining only the last 3 full ones
    remove_all_but_n_full: 3

    # Optional AWS config file with credentials.
    aws_config_file: ${home-dir}/.duplicity-unattended/aws_credentials

    # Directories to be backed up. Each one consists of a source (absolute path) and optional lists of
    # include and exclude patterns in Duplicity format.
    backup_dirs:
      - source: ${home-dir}
        includes:
          - ${home-dir}/.ssh
          - ${home-dir}/bin
          - ${home-dir}/dev
          - ${home-dir}/Documents
          - ${home-dir}/nixos-config
          - ${home-dir}/Wallpaper
          - ${home-dir}/.wireguard
          - ${home-dir}/.ssh
        excludes:
          - '**'

    # AWS!
    cloud: aws
  '';

  # User systemd units
  systemd.user = {
    # Duplicity backups
    services.duplicity-unattended = {
      Unit.Description = "Unattended Duplicity backup";
      Service = {
        Type = "oneshot";
        ExecStart = "${inputs.duplicity-unattended.defaultPackage.x86_64-linux}/bin/duplicity-unattended --config ${home-dir}/.duplicity-unattended/config.yaml";
      };
    };
    timers.duplicity-unattended = {
      Unit.Description = "Run daily Duplicity backup";
      Timer = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "20min";
      };
      Install.WantedBy = [ "timers.target" ];
    };

    # Media sync from S3
    services.media-sync-down = {
      Unit.Description = "Sync media from S3 to local";
      Service = {
        Type = "oneshot";
        ExecStart = "${home-dir}/bin/media-sync-down";
      };
    };
    timers.media-sync-down = {
      Unit.Description = "Run daily media sync from S3";
      Timer = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "20min";
      };
      Install.WantedBy = [ "timers.target" ];
    };

    # Snapcast
    services.snapcast-sync = {
      Unit = {
        Description = "Send PipeWire audio to Snapcast";
        BindsTo = [ "pipewire.service" ];
        After = [ "pipewire.service" ];
      };
      Install = {
        WantedBy = [ "pipewire.service" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.pulseaudio}/bin/pactl load-module module-pipe-sink file=/run/snapserver/dispatch sink_name=Snapcast format=s16le rate=48000";
      };
    };
  };

}
