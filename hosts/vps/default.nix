{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./disko.nix
  ];

  config = {
    system.stateVersion = "24.11";
    time.timeZone = "Europe/Helsinki";
    networking.hostName = "uwu";

    nix.gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };

    meow = {
      impermanence.enable = true;
      impermanence.persist = "/nix/persist";
    };

    # boot.initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
    # boot.kernelModules = ["kvm-intel"];
    # boot.extraModulePackages = [];
    boot.kernel.sysctl = {
      "fs.inotify.max_user_watches" = "1048576";
    };

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
