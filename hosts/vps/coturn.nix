{config, ...}: {
  config = {
    services.coturn = rec {
      enable = true;
      use-auth-secret = true;
      static-auth-secret-file = config.sops.secrets.coturn_secret.path;

      min-port = 49000;
      max-port = 50000;

      no-cli = true;
      no-tcp-relay = true;
      realm = "saatana.xyz";

      cert = "/var/lib/acme/${realm}/cert.pem";
      pkey = "/var/lib/acme/${realm}/key.pem";
    };

    sops.secrets.coturn_secret.owner = "turnserver";
    sops.secrets.coturn_secret.group = "turnserver";

    users.users.turnserver.extraGroups = ["acme"];

    networking.firewall = {
      allowedUDPPortRanges = with config.services.coturn; [
        {
          from = min-port;
          to = max-port;
        }
      ];

      allowedUDPPorts = [3478 5349];
      allowedTCPPorts = [3478 5349];
    };
  };
}
