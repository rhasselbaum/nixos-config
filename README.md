My NixOS configurations. Perhaps some will find it useful.

#### Basic steps for bootstrapping a new host

Boot into live medium, then, if using Disko (not Raspberry Pi / ARM image):

```bash
cd /tmp
git clone https://github.com/rhasselbaum/nixos-config.git
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode disko nixos-config/hosts/<host>/disk-config.nix
```

You should see partitions mounted under `/mnt` after this. Then:

```bash
sudo nixos-generate-config --no-filesystems --root /mnt
```

Copy the generated `hardware-configuration.nix` into the repo if needed and push it to Github. Then:

```bash
sudo rm /mnt/etc/nixos/*
sudo git clone https://github.com/rhasselbaum/nixos-config.git /mnt/etc/nixos
cd /mnt/etc/nixos
sudo nixos-install --flake /mnt/etc/nixos#<host>
```

After reboot, log in as yourself. Then:

```bash
cd ~
git clone https://github.com/rhasselbaum/nixos-config.git
cd /etc
sudo rm -rf nixos
sudo ln -s /home/rob/nixos-config nixos
```