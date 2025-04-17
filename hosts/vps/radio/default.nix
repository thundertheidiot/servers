{...}: {
  config = {
    services.icecast = {
      enable = true;
      hostname = "localhost";
      listen.address = "localhost";
      listen.port = 8002;

      # should only be listening on localhost
      admin.password = "icecast";
    };

    services.liquidsoap.streams = {
      radio = ./radio.liq;
    };
  };
}
