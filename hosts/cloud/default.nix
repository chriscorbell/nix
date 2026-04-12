{ lib, pkgs, ... }:
{
  imports = [
    ../../modules/nixos/common
    ./hardware-configuration.nix
  ];

  networking.hostName = "cloud";
  my.remoteDocker = {
    enable = true;
  };
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
    trustedInterfaces = [ "tailscale0" ];
    logRefusedConnections = false;
  };

  security.apparmor.enable = true;
  security.sudo.execWheelOnly = true;

  boot.blacklistedKernelModules = [
    "dccp"
    "sctp"
    "rds"
    "tipc"
    "n-hdlc"
    "ax25"
    "netrom"
    "rose"
    "x25"
    "decnet"
    "econet"
    "af_802154"
    "ipx"
    "appletalk"
    "psnap"
    "p8023"
    "p8022"
    "can"
    "atm"
  ];

  environment.systemPackages = with pkgs; [
    ghostty.terminfo
    nodejs
  ];

  users.users.chris.extraGroups = lib.mkAfter [ "networkmanager" ];
  security.sudo.wheelNeedsPassword = true;

  system.activationScripts.hardenChrisSshPermissions.text = ''
    if [ -d /home/chris/.ssh ]; then
      chmod 700 /home/chris/.ssh
      if [ -f /home/chris/.ssh/authorized_keys ]; then
        chmod 600 /home/chris/.ssh/authorized_keys
      fi
    fi
  '';

  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "kernel.sysrq" = 0;
    "kernel.perf_event_paranoid" = 3;
    "kernel.kexec_load_disabled" = 1;
    "kernel.unprivileged_bpf_disabled" = 1;
    "kernel.yama.ptrace_scope" = 2;
    "vm.unprivileged_userfaultfd" = 0;
    "fs.protected_hardlinks" = 1;
    "fs.protected_symlinks" = 1;
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;
    "fs.suid_dumpable" = 0;
    "net.core.bpf_jit_harden" = 2;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.default.accept_source_route" = 0;
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.tcp_rfc1337" = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.conf.default.log_martians" = 1;
  };

  security.auditd.enable = true;
  systemd.coredump.enable = false;
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "hard";
      item = "core";
      value = "0";
    }
  ];

  services.openssh = {
    ports = [ 41763 ];
    openFirewall = false;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AuthenticationMethods = "publickey";
      AllowUsers = [ "chris" ];
      MaxAuthTries = 3;
      LoginGraceTime = "30s";
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
      LogLevel = "VERBOSE";
      X11Forwarding = false;
      AllowAgentForwarding = false;
      AllowTcpForwarding = "no";
      AllowStreamLocalForwarding = "no";
      GatewayPorts = "no";
      PermitTunnel = false;
      PermitUserEnvironment = "no";
      PermitUserRC = "no";
      UseDns = false;
      VersionAddendum = "none";
    };
    extraConfig = ''
      Match User chris
        AllowTcpForwarding yes
      Match User chris Address *,!100.64.0.0/10,!fd7a:115c:a1e0::/48
        RefuseConnection yes
    '';
  };

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";
    ignoreIP = [ "127.0.0.1/8" "::1" "100.64.0.0/10" "fd7a:115c:a1e0::/48" ];
    jails.sshd.settings = {
      enabled = true;
      mode = "aggressive";
      port = "41763";
      findtime = "10m";
      maxretry = 4;
      bantime = "1h";
    };
  };

  services.journald.extraConfig = ''
    Storage=persistent
    SystemMaxUse=500M
    MaxRetentionSec=14day
  '';

  system.autoUpgrade = {
    enable = true;
    dates = "03:30";
    randomizedDelaySec = "45min";
    allowReboot = true;
    rebootWindow = {
      lower = "03:30";
      upper = "05:30";
    };
  };
}
