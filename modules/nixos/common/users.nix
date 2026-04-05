{ pkgs, ... }:
{
  users.users.chris = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    hashedPassword = "$y$j9T$EUZq8mja/o9MlpBWiPK0e/$dRiAy7yapAfU8ZhPRzjZgC/p0Z5TaFflSI6UUz8IK72";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDn5vaXh3vNvgZLDM4QhAqwLvUy/fwUpnuDPnWNrnKf1 hi@chriscorbell.com"
    ];
    packages = [ ];
  };
}
