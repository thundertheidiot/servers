{
  config,
  pkgs,
  ...
}: {
  config = {
    services.murmur = {
      enable = true;
      openFirewall = true;

      sslCert = "/var/lib/acme/saatana.xyz/cert.pem";
      sslKey = "/var/lib/acme/saatana.xyz/key.pem";
      bandwidth = 120000;
    };

    users.users."${config.services.murmur.user}".extraGroups = ["acme"];

    services.botamusique = {
      enable = true;
      # package = pkgs.botamusique.override {
      #   python3Packages = pkgs.python310Packages;
      # };
    };
  };
}
