{ lib, pkgs, ... }:
{
  imports = [
    ../../modules/nixos/common
    ./hardware-configuration.nix
  ];

  networking.hostName = "devbox";
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

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
