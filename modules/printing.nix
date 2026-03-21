# CUPS printing and local printer discovery via Avahi.
{ ... }:
{
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
