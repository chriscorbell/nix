{ lib, pkgs, ... }:
{
  imports = [
    ../../modules/nixos/common
    ./hardware-configuration.nix
  ];

  networking.hostName = "devbox";
  my.remoteDocker = {
    enable = true;
  };
  networking.useDHCP = false;
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  networking.interfaces.ens18.ipv4.addresses = [
    {
      address = "10.0.0.24";
      prefixLength = 24;
    }
  ];
  networking.defaultGateway = {
    address = "10.0.0.1";
    interface = "ens18";
  };
  networking.firewall.enable = false;

  # Let Tailscale program DNS via MagicDNS instead of pinning nameservers here.
  services.resolved.enable = true;

  environment.systemPackages = with pkgs; [
    bun
    dig
    ghostty.terminfo
    hugo
    iperf3
    iproute2
    nil
    nix-output-monitor
    nix-tree
    nodejs_24
    pnpm
    python3
    python3Packages.pip
    python3Packages.virtualenv
    socat
    strace
    unzip
    zip
  ];

  users.users.chris.extraGroups = lib.mkAfter [ "docker" "networkmanager" ];
  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AllowUsers = [ "chris" ];
      AllowAgentForwarding = true;
      AllowTcpForwarding = "yes";
    };
  };
}
