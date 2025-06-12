{ ... }:

{
  home.file = {
    "bin/http-log-server" = {
      source = ./bin/http-log-server;
      executable = true;
    };
  };
}
