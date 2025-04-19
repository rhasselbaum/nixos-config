# Home Manager config for amy
{ config, pkgs, inputs, ... }:
let
  common-homeenv = inputs.common-homeenv;
  home-dir = "/home/amy";
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "amy";
  home.homeDirectory = home-dir;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Duplicity backups. On new systems, you need to create ~/.duplicity-unattended/aws_credentials and import your GPG key.
  # Obviously not including those here.
  home.file.".duplicity-unattended/config.yaml".text = ''
    ########################################################################
    # Config options for Duplicity host backup.
    ########################################################################

    # GnuPG key ID used for encryption and signing.
    gpg_key_id: C4F550686E3F518FC0AE4867E63BD16F2A426241

    # S3 bucket name and optional prefix in Duplicity URL format.
    bucket_url: s3:///amethyst-backup

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
          - ${home-dir}/Documents
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
  };
}
