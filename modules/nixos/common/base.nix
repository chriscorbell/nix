{ ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/New_York";

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    optimise.automatic = true;
  };

  nixpkgs.config.allowUnfree = true;
  programs.nix-ld.enable = true;

  services.openssh.enable = true;
  services.tailscale.enable = true;
  virtualisation.docker.enable = true;

  system.stateVersion = "25.11";
}
