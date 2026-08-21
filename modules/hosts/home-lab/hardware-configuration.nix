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

    boot.initrd.availableKernelModules = [ "virtio_pci" "uhci_hcd" "ehci_pci" "ahci" "sr_mod" "virtio_blk" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/10ee6bb8-d952-4e01-90fa-fcb92ab0cb47";
        fsType = "btrfs";
      };

    fileSystems."/home" =
      { device = "/dev/disk/by-uuid/10ee6bb8-d952-4e01-90fa-fcb92ab0cb47";
        fsType = "btrfs";
        options = [ "subvol=home" ];
      };

    fileSystems."/nix" =
      { device = "/dev/disk/by-uuid/10ee6bb8-d952-4e01-90fa-fcb92ab0cb47";
        fsType = "btrfs";
        options = [ "subvol=nix" ];
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/DBA0-E877";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

    swapDevices = [ ];
  };
}
