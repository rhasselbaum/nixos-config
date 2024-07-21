# Home Manager config for rob
{ config, pkgs, inputs, ... }:
let
  common-homeenv = inputs.common-homeenv;
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "rob";
  home.homeDirectory = "/home/rob";

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

  # Common home env repo, used for non-Nix, too.
  home.file.".vimrc".source = "${common-homeenv}/.vimrc";
  home.file.".gitconfig".source = "${common-homeenv}/.gitconfig";

  # Only take certain Fish config, let the rest be defined on the host.
  home.file.".config/fish/functions/fish_greeting.fish".source = "${common-homeenv}/.config/fish/functions/fish_greeting.fish";
  home.file.".config/fish/functions/fish_prompt.fish".source = "${common-homeenv}/.config/fish/functions/fish_prompt.fish";
  home.file.".config/fish/conf.d".source = "${common-homeenv}/.config/fish/conf.d";

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
    aws_config_file: /home/rob/.duplicity-unattended/aws_credentials

    # Directories to be backed up. Each one consists of a source (absolute path) and optional lists of
    # include and exclude patterns in Duplicity format.
    backup_dirs:
      - source: /home/rob
        includes:
          - /home/rob/.ssh
          - /home/rob/bin
          - /home/rob/dev
          - /home/rob/Documents
          - /home/rob/nixos-config
          - /home/rob/Wallpaper
        excludes:
          - '**'

    # AWS!
    cloud: aws
  '';

  # Units for backups.
  systemd.user = {
    services.duplicity-unattended = {
      Unit.Description = "Unattended Duplicity backup";
      Service = {
        Type = "oneshot";
        ExecStart = "${inputs.duplicity-unattended.defaultPackage.x86_64-linux}/bin/duplicity-unattended --config .duplicity-unattended/config.yaml";
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
