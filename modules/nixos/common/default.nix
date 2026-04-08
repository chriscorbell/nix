{
  imports = [
    ./base.nix
    ./docker-remote-tailscale.nix
    ../../shared/terminal-packages.nix
    ./users.nix
    ./zsh.nix
    ../../shared/starship.nix
  ];
}
