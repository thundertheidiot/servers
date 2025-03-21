{...}: {
  config = {
    sops.secrets = {
      torrent_stack_env = {
        sopsFile = ./torrent_stack_env;
        format = "binary";
      };

      homepage_env = {
        sopsFile = ./homepage.env;
        format = "dotenv";
      };

      rathole = {
        sopsFile = ./rathole.toml;
        format = "binary";
      };

      authentik_env = {
        sopsFile = ./authentik.env;
        format = "dotenv";
      };
    };
  };
}
