{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    ./acme.nix
    ./coturn.nix
    ./disko.nix
    ./mail.nix
    ./prosody
    ./secrets
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  config = {
    system.stateVersion = "24.11";
    time.timeZone = "Europe/Helsinki";

    networking = let
      interface = "ens18";
      ipv4 = "185.243.215.32";
      ipv6 = "2a09:cd42:f:42db";
    in {
      hostName = "owo";
      networkmanager.enable = false;

      # TODO these for real server
      interfaces."${interface}" = {
        ipv4.addresses = [
          {
            address = ipv4;
            prefixLength = 24;
          }
        ];

        ipv6.addresses = [
          {
            address = "${ipv6}::1";
            prefixLength = 124;
          }
        ];
      };

      defaultGateway = "185.243.215.1";
      defaultGateway6 = {
        address = "${ipv6}::f";
        inherit interface;
      };
      nameservers = ["1.1.1.1" "2606:4700:4700:1111"];
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
