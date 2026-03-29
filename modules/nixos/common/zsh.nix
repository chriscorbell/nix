import ../../shared/mk-zsh.nix {
  visual = "nano";
  rsCommand = config: "sudo nixos-rebuild switch --flake ~/.config/nix#${config.networking.hostName}";
  rsuCommand = config: "cd ~/.config/nix && nix flake update && sudo nixos-rebuild switch --flake ~/.config/nix#${config.networking.hostName}";
}
