{config, ...}: {
  config = {
    sops.secrets."authentik_env".mode = "0644";

    meow.impermanence.directories = [
      {
        path = "/var/lib/postgresql";
      }
    ];

    services.authentik = {
      enable = true;
      environmentFile = config.sops.secrets."authentik_env".path;

      settings = {
        disable_startup_analytics = true;
        avatars = "initials";
      };
    };
  };
}
