{
  disko.devices = {
    disk = {
      root = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypt-root";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [ "rw" "relatime" "compress=zstd:3" "ssd" "space_cache=v2" ];
                    };
                    "/swap" = {
                      mountpoint = "/swap";
                      swap.swapfile.size = "64G";
                      swap.swapfile.path = "swapfile";
                    };
                  };
                };
              };
            };
          };
        };
      };
      aux = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypt-aux";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/aux" = {
                      mountpoint = "/aux";
                      mountOptions = [ "rw" "relatime" "compress=zstd:3" "ssd" "space_cache=v2" ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
