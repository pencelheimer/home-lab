{...}: {
  flake.nixosModules.home-lab = {modulesPath, lib, ...}: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")

      # TODO: remove on actual hardware
      (modulesPath + "/profiles/qemu-guest.nix")
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    # TODO: maybe remove this and import module from the nixos hardware configs collection
    hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
    hardware.graphics.enable = lib.mkDefault true;

    # TODO: replace with real hardware instead of qemu guest

    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/1bca2463-54c0-4016-9706-f714de3c51c1";
        fsType = "btrfs";
      };

    fileSystems."/home" =
      { device = "/dev/disk/by-uuid/1bca2463-54c0-4016-9706-f714de3c51c1";
        fsType = "btrfs";
        options = [ "subvol=home" ];
      };

    fileSystems."/nix" =
      { device = "/dev/disk/by-uuid/1bca2463-54c0-4016-9706-f714de3c51c1";
        fsType = "btrfs";
        options = [ "subvol=nix" ];
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/AAA7-97B9";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

    swapDevices =
      [ { device = "/dev/disk/by-uuid/8ebcf856-740b-4f2f-b86b-6eb7a890cb2f"; }
      ];
  };
}
