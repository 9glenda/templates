{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];
  sys.nix.flakes = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.requestEncryptionCredentials = true;
  system.stateVersion = "23.05"; # Did you read the comment?
  networking.hostName = "main";
}
