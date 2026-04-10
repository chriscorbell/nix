{ lib, pkgs, ... }:
{
  imports = [
    ../../modules/nixos/common
    ./hardware-configuration.nix
  ];

  networking.hostName = "docker";
  services.tailscale.extraSetFlags = [ "--ssh" ];
  my.remoteDocker = {
    enable = true;
  };
  networking.useDHCP = false;
  networking.interfaces.ens18.ipv4.addresses = [
    {
      address = "10.0.0.22";
      prefixLength = 24;
    }
  ];
  networking.defaultGateway = {
    address = "10.0.0.1";
    interface = "ens18";
  };
  networking.nameservers = [ "10.0.0.2" ];
  networking.firewall.enable = false;

  environment.systemPackages = with pkgs; [
    cifs-utils
    clinfo
    git-credential-manager
    ghostty.terminfo
    intel-compute-runtime
    intel-gpu-tools
    intel-media-driver
    libva-utils
    nfs-utils
    nodejs
    level-zero
    vpl-gpu-rt
  ];

  services.qemuGuest.enable = true;

  fileSystems."/tank" = {
    device = "10.0.0.21:/";
    fsType = "nfs";
    options = [
      "_netdev"
      "nofail"
      "x-systemd.after=network-online.target"
      "x-systemd.requires=network-online.target"
      "nfsvers=4.2"
    ];
  };

  hardware.enableRedistributableFirmware = true;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      clinfo
      intel-gpu-tools
      intel-media-driver
      intel-compute-runtime
      level-zero
      libva-utils
      vpl-gpu-rt
    ];
  };

  security.wrappers.intel_gpu_top = {
    owner = "root";
    group = "root";
    source = "${pkgs.intel-gpu-tools}/bin/intel_gpu_top";
    capabilities = "cap_perfmon+ep";
  };

  users.users.chris.extraGroups = lib.mkAfter [ "docker" ];
  security.sudo.wheelNeedsPassword = false;

  systemd.services.docker-data-backup =
    let
      backupRoot = "/tank/backup/docker";
      backupScript = pkgs.writeShellScript "docker-data-backup" ''
        set -euo pipefail

        export PATH=${lib.makeBinPath [
          pkgs.bash
          pkgs.coreutils
          pkgs.docker
          pkgs.findutils
          pkgs.gnused
          pkgs.rsync
        ]}

        src="/home/chris/data/"
        dst_root="${backupRoot}"
        retention=30
        timestamp="$(date +%Y-%m-%d_%H-%M-%S)"
        staging_dir="$dst_root/.staging-$timestamp"
        final_dir="$dst_root/$timestamp"
        log_file="$dst_root/backup-warnings.log"
        paused_containers=""

        log_warn() {
          printf '%s [warn] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$log_file"
        }

        log_error() {
          printf '%s [error] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$log_file"
        }

        cleanup() {
          if [ -n "$paused_containers" ]; then
            docker unpause $paused_containers >/dev/null || true
          fi
          if [ -d "$staging_dir" ]; then
            rm -rf "$staging_dir"
          fi
        }

        run_rsync() {
          local rc=0
          rsync "''${rsync_args[@]}" "$src" "$staging_dir/" 2>>"$log_file" || rc=$?
          if [ "$rc" -eq 24 ]; then
            log_warn "rsync reported vanished source files during live copy for snapshot $timestamp"
          fi
          if [ "$rc" -ne 0 ] && [ "$rc" -ne 24 ]; then
            log_error "rsync failed with exit code $rc for snapshot $timestamp"
            return "$rc"
          fi
        }

        trap cleanup EXIT

        mkdir -p "$dst_root"
        touch "$log_file"

        rsync_args=(
          --archive
          --hard-links
          --numeric-ids
          --delete
          --delete-delay
          --human-readable
        )

        mkdir -p "$staging_dir"
        run_rsync

        if systemctl -q is-active docker.service; then
          paused_containers="$(docker ps -q | tr '\n' ' ' | sed 's/[[:space:]]*$//')"
          if [ -n "$paused_containers" ]; then
            docker pause $paused_containers >/dev/null 2>>"$log_file"
          fi

          run_rsync

          if [ -n "$paused_containers" ]; then
            docker unpause $paused_containers >/dev/null 2>>"$log_file"
            paused_containers=""
          fi
        fi

        mv "$staging_dir" "$final_dir"

        find "$dst_root" -mindepth 1 -maxdepth 1 -type d \
          -regextype posix-extended \
          -regex '.*/[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}' \
          | sort \
          | head -n -"$retention" \
          | xargs -r rm -rf

        trap - EXIT
      '';
    in
    {
      description = "Snapshot Docker persistent data to /tank/backup/docker";
      after = [ "network-online.target" "docker.service" ];
      wants = [ "network-online.target" ];
      unitConfig.RequiresMountsFor = [
        "/home/chris/data"
        "/tank"
        backupRoot
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = backupScript;
        User = "root";
        Group = "root";
        Nice = 10;
        IOSchedulingClass = "best-effort";
        IOSchedulingPriority = 7;
      };
    };

  systemd.timers.docker-data-backup = {
    description = "Scheduled Docker persistent data backup";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 03:15:00";
      RandomizedDelaySec = "30m";
      Persistent = true;
      Unit = "docker-data-backup.service";
    };
  };

  systemd.services.frigate-fix-perms =
    let
      frigateMediaRoot = "/tank/media/frigate";
      fixFrigatePerms = pkgs.writeShellScript "frigate-fix-perms" ''
        set -euo pipefail

        export PATH=${lib.makeBinPath [
          pkgs.coreutils
          pkgs.findutils
        ]}

        if [ ! -d "${frigateMediaRoot}" ]; then
          exit 0
        fi

        find "${frigateMediaRoot}" -type d -exec chown chris:users {} +
        find "${frigateMediaRoot}" -type d -exec chmod 2775 {} +
        find "${frigateMediaRoot}" -type f -exec chown chris:users {} +
        find "${frigateMediaRoot}" -type f -exec chmod 664 {} +
      '';
    in
    {
      description = "Normalize Frigate media ownership";
      after = [ "docker.service" ];
      unitConfig.RequiresMountsFor = [ frigateMediaRoot ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = fixFrigatePerms;
        User = "root";
        Group = "root";
      };
    };

  systemd.timers.frigate-fix-perms = {
    description = "Periodically normalize Frigate media ownership";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2m";
      OnUnitActiveSec = "1m";
      Persistent = true;
      Unit = "frigate-fix-perms.service";
    };
  };
}
