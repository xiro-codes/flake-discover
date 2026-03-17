{
  description = "NixOS system configuration with flake-discover";
  inputs = {
    flake-discover.url = "github:xiro-codes/flake-discover";
    home-manager.url = "github:nix-community/home-manager";
  };
  outputs = { self, nixpkgs, flake-discover, home-manager, ... }@inputs:
    let
      discovered = flake-discover.lib.discover {
        root = ./.;
        collectors = flake-discover.lib.collectors.defaultCollectors nixpkgs inputs;
      };
    in
    {
      inherit (discovered)
        nixosConfigurations
        homeManagerConfiguration
        nixosModules
        homeModules
        packages
        templates
        devShells;

    };
}
