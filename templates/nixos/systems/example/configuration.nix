{ pkgs, config, lib, ... }: {
  imports = [
    #./hardware-configuration.nix
  ];
  system.stateVersion = "25.11";
}
