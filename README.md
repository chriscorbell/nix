# Unified Nix Config

This repository consolidates three machines into one flake:

- `docker`: the NixOS host that runs Docker at home
- `oracle-vps`: the NixOS VPS in the cloud
- `mbp`: the MacBook Pro managed by `nix-darwin`

## Layout

```text
.
├── flake.nix
├── hosts/
│   ├── docker/
│   ├── mbp/
│   └── oracle-vps/
├── modules/
│   ├── nixos/common/
│   └── shared/
└── scripts/apply
```

Shared Linux concerns live in `modules/nixos/common`, host-specific concerns live under `hosts/<name>`, and the shared Starship prompt lives in `modules/shared/starship.nix`.

## Applying a Host

Clone the repo onto the target machine at `~/.config/nix`.

Linux:

```sh
sudo nixos-rebuild switch --flake ~/.config/nix#docker
sudo nixos-rebuild switch --flake ~/.config/nix#oracle-vps
```

macOS:

```sh
sudo darwin-rebuild switch --flake ~/.config/nix#mbp
```

Or use the helper:

```sh
~/.config/nix/scripts/apply
~/.config/nix/scripts/apply docker
~/.config/nix/scripts/apply oracle-vps
~/.config/nix/scripts/apply mbp
```

## Hardware Configuration

The two NixOS hosts import repo-local hardware files:

- `hosts/docker/hardware-configuration.nix`
- `hosts/oracle-vps/hardware-configuration.nix`

For `docker`, the real generated file is already tracked in the repo.

For `oracle-vps`, the tracked file is currently a placeholder. Replace it with a generated hardware file before rebuilding that host:

```sh
sudo nixos-generate-config --show-hardware-config > ~/.config/nix/hosts/oracle-vps/hardware-configuration.nix
```

## Migration Notes

- The old repos were left untouched in `/Users/chris/git`.
- The MacBook Pro config was migrated into `hosts/mbp/default.nix`.
- Shared Linux package, shell, user, and base system settings were deduplicated into reusable modules.
- The canonical checkout path is `~/.config/nix` on all three hosts.
- `docker` includes its generated hardware file in the repo.
- `oracle-vps` keeps a tracked placeholder hardware file until that VM is recreated.
