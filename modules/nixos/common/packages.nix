{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    atuin
    bat
    btop
    curl
    eza
    file
    git
    less
    starship
    wget
    zoxide
    zsh
  ];
}
