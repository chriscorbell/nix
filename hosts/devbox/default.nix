{ lib, pkgs, ... }:
{
  imports = [
    ../../modules/nixos/common
    ./hardware-configuration.nix
  ];

  networking.hostName = "devbox";
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
    fd
    fzf
    gh
    hugo
    iperf3
    iproute2
    jq
    just
    lazydocker
    lazygit
    lsof
    mtr
    nil
    nix-output-monitor
    nix-tree
    nodejs_24
    pnpm
    python3
    python3Packages.pip
    python3Packages.virtualenv
    ripgrep
    rsync
    shellcheck
    shfmt
    socat
    strace
    tmux
    unzip
    uv
    yq-go
    zip
  ];

  users.users.chris.extraGroups = lib.mkAfter [ "networkmanager" ];
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
