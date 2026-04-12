{ pkgs, ... }:
{
  users.users.chris = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMSc9gHrkDHjyiDVKCPOIm1aJlbAGswe01RpgEsWdFV"
    ];
    packages = [ ];
  };
}
