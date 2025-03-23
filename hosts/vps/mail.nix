{
  config,
  pkgs,
  ...
}: let
  p = dir: "${config.meow.impermanence.persist}/${dir}";
in {
  config = {
    mailserver = {
      enable = true;

      sieveDirectory = p "mail/sieve";
      mailDirectory = p "mail/vmail";
      dkimKeyDirectory = p "mail/dkim";
      backup.snapshotRoot = p "mail/rsnapshot";
      indexDir = p "mail/index";

      fqdn = "mail.saatana.xyz";
      domains = ["saatana.xyz"];

      loginAccounts = {
        # nix-shell -p mkpasswd --run "mkpasswd -sm bcrypt"
        "perkele@saatana.xyz" = {
          hashedPassword = "$2b$05$7GdXl3NnetmS8yW4SL8UEuyhjtqDrkwk8r7sup8khTQZmcDcY8n7e";
        };
      };

      certificateScheme = "acme-nginx";
    };

    meow.impermanence.directories = [
      {path = "/var/lib/postgresql";}
      {path = "/var/lib/dovecot";}
      {path = "/var/lib/postfix";}
      {path = "/var/lib/opendkim";}
      {path = "/var/spool/mail";}
      {path = "/var/cache/knot-resolver";}
      {path = "/var/lib/rspamd";}
    ];

    services.roundcube = {
      enable = true;
      hostName = config.mailserver.fqdn;
      extraConfig = ''
        $config['smtp_server'] = "tls://${config.mailserver.fqdn}";
        $config['smtp_user'] = "%u";
        $config['smtp_pass'] = "%p";
      '';
    };
  };
}
