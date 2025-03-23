{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    ./acme.nix
    ./disko.nix
    ./mail.nix
    ./prosody.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  config = {
    system.stateVersion = "24.11";
    time.timeZone = "Europe/Helsinki";
    networking.hostName = "uwu";

    networking = {
      networkmanager.enable = false;

      interfaces.ens18.ipv4.addresses = [
        {
          address = "185.243.215.32";
          prefixLength = 24;
        }
      ];

      defaultGateway = "185.243.215.1";
      nameservers = ["1.1.1.1"];
    };

    nix.gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };

    meow = {
      impermanence.enable = true;
      impermanence.persist = "/nix/persist";
    };

    server.getCerts = ["saatana.xyz"];
    services.nginx.virtualHosts."saatana.xyz" = {
      root = ./http;
    };

    users.users.root.initialPassword = "password";

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
