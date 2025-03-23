{
  lib,
  pkgs,
  ...
}: {
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBKwHM/9spQfyeNIl/p8N8XBuoKj8UrhuhhlbEwkrgjZ thunder@disroot.org"
  ];

  # dumb? yes, i'm lazy though
  networking.networkmanager.enable = lib.mkDefault true;
  # systemd.services."NetworkManager-wait-online".enable = false;

  environment.systemPackages = with pkgs; [
    nh
    btop
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # needed for vpns
  networking.firewall.checkReversePath = false;

  sops.age.keyFile = "/nix/persist/sops-key.txt";

  security.sudo.enable = lib.mkForce false;
  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
  };
}
