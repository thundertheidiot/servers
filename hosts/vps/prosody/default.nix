{
  config,
  mlib,
  lib,
  ...
}: let
  inherit (lib.types) listOf str;
  inherit (mlib) mkOpt;
  inherit (builtins) head tail listToAttrs concatStringsSep;
in {
  options = {
    server.xmppDomains = mkOpt (listOf str) ["saatana.xyz"] {};
  };

  config = let
    mainDomain = head config.server.xmppDomains;
  in {
    server.getCerts = config.server.xmppDomains;
    security.acme.certs =
      listToAttrs (map (name: {
          inherit name;
          value = {
            extraDomainNames = [
              "chat.${name}"
            ];
          };
        })
        (tail
          config.server.xmppDomains))
      // {
        "${mainDomain}" = {
          extraDomainNames = [
            "chat.${mainDomain}"
            "upd.${mainDomain}"
            "proxy.${mainDomain}"
            "pubsub.${mainDomain}"
          ];
        };
      };

    networking.firewall.allowedTCPPorts =
      config.services.prosody.httpsPorts
      ++ config.services.prosody.httpPorts
      ++ [
        5000 # proxy
        5222 # c2s
        5269 # s2s
      ];

    meow.impermanence.directories = [
      {path = "/var/lib/prosody";}
    ];

    services.prosody = {
      enable = true;
      xmppComplianceSuite = true;

      allowRegistration = true;

      extraConfig = ''
        certificates = "/var/lib/acme";

        local function read_file(path)
          local file = io.open(path, "r")
          if not file then
            return nil, "Could not open file: " .. path
          end
          local content = file:read("*a")
          file:close()
          return content
        end

        turn_external_host = "${mainDomain}"
        turn_external_secret = read_file("${config.sops.secrets.coturn_secret.path}")

        Component "proxy.${mainDomain}" "proxy65"
          proxy65_address = "proxy.${mainDomain}"
          proxy65_acl = { "${concatStringsSep "\", \"" config.server.xmppDomains}" }
      '';

      extraModules = ["vcard4" "turn_external"];

      modules = {
        roster = true;
        saslauth = true;
        tls = true;
        dialback = true;
        disco = true;
        blocklist = true;
        private = true;
        # vcard = true;
        vcard_legacy = true;
        mam = true;
        carbons = true;
        csi = true;
        version = true;
        uptime = true;
        time = true;
        ping = true;
        pep = true;
        register = true;
        watchregistrations = true;
        admin_adhoc = true;
        bookmarks = true;
        smacks = true;
        cloud_notify = true;

        proxy65 = false;
      };

      uploadHttp = {
        domain = "upd.${mainDomain}";
        uploadFileSizeLimit = "100*1024*1024";
        userQuota = 1024 * 1024 * 2048;
        httpUploadPath = config.services.prosody.dataDir;
      };
      httpFileShare.domain = config.services.prosody.uploadHttp.domain;

      virtualHosts = listToAttrs (map (d: {
          name = d;
          value = {
            enabled = true;
            domain = d;

            ssl.cert = "/var/lib/acme/${d}/cert.pem";
            ssl.key = "/var/lib/acme/${d}/key.pem";
          };
        })
        config.server.xmppDomains);

      disco_items =
        [
          {
            url = "upd.${mainDomain}";
            description = "file upload";
          }
          {
            url = "proxy.${mainDomain}";
            description = "proxy";
          }
          {
            url = "pubsub.${mainDomain}";
            description = "pubsub";
          }
        ]
        ++ (map (d: {
            url = "chat.${d}";
            description = "Muc";
          })
          config.server.xmppDomains);

      muc =
        map (d: {
          name = "Prosody Chatrooms";
          restrictRoomCreation = "local";
          roomDefaultMembersOnly = true;
          roomDefaultPublic = false;
          domain = "chat.${d}";
          vcard_muc = true;
        })
        config.server.xmppDomains;
    };

    users.users."${config.services.prosody.user}".extraGroups = ["acme" "turnserver"];
  };
}
