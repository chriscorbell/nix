{ lib, config, ... }:
let
  cfg = config.my.remoteDocker;
in
{
  options.my.remoteDocker = {
    enable = lib.mkEnableOption "Docker TCP listener";

    port = lib.mkOption {
      type = lib.types.port;
      default = 2375;
      description = "TCP port exposed by dockerd on the Tailscale interface.";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.daemon.settings.hosts = lib.mkForce [
      "unix:///var/run/docker.sock"
      "tcp://0.0.0.0:${toString cfg.port}"
    ];
  };
}
