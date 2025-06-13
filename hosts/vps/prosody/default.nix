{
  config,
  mlib,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.types) listOf str;
  inherit (mlib) mkOpt;
  inherit (builtins) head tail listToAttrs concatStringsSep;
in {
  imports = [./module.nix];
  disabledModules = ["services/networking/prosody.nix"];

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
          ];
        };
      };

    users.users."${config.services.prosody.user}".extraGroups = ["acme" "turnserver"];

    meow.impermanence.directories = [
      {path = config.services.prosody.dataDir;}
    ];

    services.prosody = {
      enable = true;
      openFirewall = true;

      virtualHosts = listToAttrs (map (name: {
          inherit name;
          value = {};
        })
        config.server.xmppDomains);

      components = {
        "upd.${mainDomain}" = {
          module = "http_upload";
          settings = {
            http_upload_file_size_limit = "100*1024*1024";
            http_upload_file_daily_quota = "1024*1024*1024";
            http_upload_file_global_quota = "1024*1024*2048";

            ssl = {
              ciphers = "HIGH:!aNULL:!eNULL:!EXP:!SSLv2:!SSLv3";
              options = ["no_sslv2" "no_sslv3" "no_ticket" "no_compression"];
              protocol = "tlsv1_2+";
            };
          };
        };

        "chat.${mainDomain}" = {
          module = "muc";
          settings = {
            modules_enabled = ["vcard_muc"];
            restrict_room_creation = "local";
            muc_room_default_public = false;
            muc_room_default_members_only = true;
          };
        };
      };

      settings = {
        turn_external_host = mainDomain;
        modules_enabled = [
          "turn_external"
        ];

        default_storage = "sql";
        sql = {
          driver = "SQLite3";
          database = "prosody.sqlite";
        };
      };

      extraConfig = ''
        local function read_file(path)
          local file = io.open(path, "r")
          if not file then
            return nil, "Could not open file: " .. path
          end
          local content = file:read("*a")
          file:close()
          return content
        end

        turn_external_secret = read_file("${config.sops.secrets.coturn_secret.path}")
      '';
    };
  };
}
