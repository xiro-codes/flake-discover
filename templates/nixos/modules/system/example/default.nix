{ config, pkgs, lib, ... }:
let
  cfg = config.local.example;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.local.example = {
    enable = mkEnableOption "enable";
  };
  config = mkIf cfg.enable { };
} 
