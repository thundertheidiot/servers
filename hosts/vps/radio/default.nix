{...}: {
  config = {
    services.icecast = {
      enable = true;
      hostname = "localhost";
      listen.address = "127.0.0.1";
      listen.port = 8002;

      # should only be listening on localhost
      admin.password = "icecast";
    };

    # systemd.services.

    services.liquidsoap.streams = {
      radio = ./radio.liq;
    };
  };
}
