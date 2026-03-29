{ pkgs, ... }:
{
  users.users.chris = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    packages = [ ];
  };
}
