{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (builtins) listToAttrs;
  inherit (lib.types) listOf str;
  inherit (mlib) mkOpt;
in {
  options = {
    server.getCerts = mkOpt (listOf str) [] {};
  };

  config = {
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "perkele@saatana.xyz";
        group = "acme";
        # staging environment
        # server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      };
    };

    users.users.nginx.extraGroups = ["acme"];

    security.acme.certs = listToAttrs (map (name: {
        inherit name;
        value = {
          group = "acme";
        };
      })
      config.server.getCerts);

    services.nginx.virtualHosts = listToAttrs (map (name: {
        inherit name;
        value = {
          forceSSL = true;
          enableACME = true;
        };
      })
      config.server.getCerts);

    meow.impermanence.directories = [
      {path = "/var/lib/acme";}
    ];
  };
}
