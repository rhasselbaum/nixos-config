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

  # Tap, tap, tap. Is this thing on?
  home.file.".hello_home_manager".text = ''
    Yep, Home Manager is indeed working.
  '';

  # Common home env repo, used for non-Nix, too.
  home.file.".vimrc".source = "${common-homeenv}/.vimrc";
  home.file.".gitconfig".source = "${common-homeenv}/.gitconfig";

  # Only take certain Fish config, let the rest be defined on the host.
  home.file.".config/fish/functions/fish_greeting.fish".source = "${common-homeenv}/.config/fish/functions/fish_greeting.fish";
  home.file.".config/fish/functions/fish_prompt.fish".source = "${common-homeenv}/.config/fish/functions/fish_prompt.fish";
  home.file.".config/fish/conf.d/abbrs.fish".source = "${common-homeenv}/.config/fish/conf.d/abbrs.fish";
}
