{
  description = "NixOS system configuration with flake-discover";
  inputs = {
    flake-discover.url = "github:xiro-codes/flake-discover";
    home-manager.url = "github:nix-community/home-manager";
  };
  outputs = { self, nixpkgs, flake-discover, home-manager, ... }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];
      discovered = flake-discover.lib.discover {
        root = ./.;
        collectors = [
          {
            name = "nixosConfigurations";
            path = "systems";
            filter = name: type: type == "directory" && name != "profiles";
            transform = name: path: nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              specialArgs = { inherit inputs; };
              modules = [ (path + "configuration.nix") ];
            };
          }
          {
            name = "homeConfigurations";
            path = "home";
            filter = name: type: type == "regular" && builtins.hasSuffix ".nix" name;
            transform = name: path: home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages."x86_64-linux";
              extraSpecialArgs = { inherit inputs; };
              modules = [ path ];
            };
          }
          {
            name = "homeModules";
            path = "modules/home";
            filter = name: type: type == "directory";
            transform = name: path: import path;
          }
          {
            name = "nixosModules";
            path = "modules/system";
            filter = name: type: type == "directory";
            transform = name: path: import path;
          }
          {
            name = "_packagePaths";
            path = "packages";
            filter = name: type: type == "directory";
            transform = name: path: path;
          }
        ];
      };
    in
    {
      inherit (discovered)
        nixosConfigurations
        homeManagerConfiguration
        nixosModules
        homeModules;

      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        builtins.mapAttrs (name: path: pkgs.callPackage path { })
          discovered._packagePaths);
    };
}
