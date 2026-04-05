# Unified Nix Config

This repository consolidates four machines into one flake:

- `devbox`
- `docker`
- `cloud`
- `mbp`

## Layout

```text
.
├── flake.nix
├── hosts/
│   ├── devbox/
│   ├── docker/
│   ├── mbp/
│   └── cloud/
├── modules/
│   ├── nixos/common/
│   └── shared/
└── scripts/apply
```

Shared NixOS concerns live in `modules/nixos/common`, host-specific concerns live under `hosts/<name>`, and the shared Starship prompt lives in `modules/shared/starship.nix`.

## Applying a Host

Clone the repo onto the target machine at `~/.config/nix`.

NixOS:

```sh
sudo nixos-rebuild switch --flake ~/.config/nix#devbox
sudo nixos-rebuild switch --flake ~/.config/nix#docker
sudo nixos-rebuild switch --flake ~/.config/nix#cloud
```

macOS:

```sh
sudo darwin-rebuild switch --flake ~/.config/nix#mbp
```

Or use the helper:

```sh
~/.config/nix/scripts/apply
~/.config/nix/scripts/apply devbox
~/.config/nix/scripts/apply docker
~/.config/nix/scripts/apply cloud
~/.config/nix/scripts/apply mbp
```

## Hardware Configuration

The NixOS hosts import repo-local hardware files:

- `hosts/devbox/hardware-configuration.nix`
- `hosts/docker/hardware-configuration.nix`
- `hosts/cloud/hardware-configuration.nix`

For `devbox`, the tracked file is currently a placeholder. Replace it with a generated hardware file before rebuilding that host:

```sh
sudo nixos-generate-config --show-hardware-config > ~/.config/nix/hosts/devbox/hardware-configuration.nix
```

For `docker`, the real generated file is already tracked in the repo.

For `cloud`, the tracked file is currently a placeholder. Replace it with a generated hardware file before rebuilding that host:

```sh
sudo nixos-generate-config --show-hardware-config > ~/.config/nix/hosts/cloud/hardware-configuration.nix
```

## Reinstalling/rebuilding NixOS hosts

1. Install NixOS with the graphical installer.
2. Choose a minimal install with no DE/WM.
3. Set:
   - username: `chris`
   - hostname: `devbox` / `docker` / `cloud`
4. Reboot and log in.
5. Install `git` if needed.
6. Clone the repo:

```sh
mkdir -p ~/.config
git clone https://github.com/chriscorbell/nix ~/.config/nix
cd ~/.config/nix
```

7. If the new install generated different disk, EFI, or swap UUIDs, regenerate the hardware file before rebuilding:

`devbox`:

```sh
sudo nixos-generate-config --show-hardware-config > ~/.config/nix/hosts/devbox/hardware-configuration.nix
```

`docker`:

```sh
sudo nixos-generate-config --show-hardware-config > ~/.config/nix/hosts/docker/hardware-configuration.nix
```

`cloud`:

```sh
sudo nixos-generate-config --show-hardware-config > ~/.config/nix/hosts/cloud/hardware-configuration.nix
```

8. Apply the system configuration:

`devbox`:

```sh
sudo nixos-rebuild switch --flake ~/.config/nix#devbox
```

`docker`:

```sh
sudo nixos-rebuild switch --flake ~/.config/nix#docker
```

`cloud`:

```sh
sudo nixos-rebuild switch --flake ~/.config/nix#cloud
```

If the hardware layout matches the tracked file already in the repo, the regeneration step can be skipped.

## Reinstalling/rebuilding for MacOS

If the MacBook Pro is wiped and reinstalled, use this workflow:

1. Install Xcode Command Line Tools:

```sh
xcode-select --install
```

2. Install Nix using the current official installer:

```sh
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```

3. Open a new terminal session after the Nix installer completes.

4. Clone the repo:

```sh
mkdir -p ~/.config
git clone https://github.com/chriscorbell/nix.git ~/.config/nix
cd ~/.config/nix
```

5. Bootstrap `nix-darwin` and apply the `mbp` configuration:

```sh
sudo nix --extra-experimental-features 'nix-command flakes' \
  run nix-darwin/master#darwin-rebuild -- \
  switch --flake ~/.config/nix#mbp
```

6. Open a new terminal session after the switch completes.

7. Future rebuilds can use:

```sh
sudo darwin-rebuild switch --flake ~/.config/nix#mbp
```

Notes:

- This assumes the macOS username is `chris`.
- This assumes the Darwin host target remains `mbp`.
- If either of those changes, update `hosts/mbp/default.nix` before the first switch.
