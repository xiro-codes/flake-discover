let

  nixosCollectors = nixpkgs: inputs: [
    {
      name = "nixosConfigurations";
      path = "systems";
      filter = name: type: type == "directory" && name != "profiles";
      transform = path: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [ (path + "/configuration.nix") ] ++ inputs.self.nixoModules;
      };
    }
    {
      name = "nixosModules";
      path = "modules/system";
      filter = name: type: type == "directory";
      transform = path: import path;
    }
  ];
  homeManagerCollectors = nixpkgs: inputs: [
    {
      name = "homeConfigurations";
      path = "home";
      filter = name: type: type == "regular" && builtins.hasSuffix ".nix" name;
      transform = path: inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = { inherit inputs; };
        modules = [ path ] ++ inputs.self.homeModules;
      };
    }
    {
      name = "homeModules";
      path = "modules/home";
      filter = name: type: type == "directory";
      transform = path: import path;
    }
  ];

  packageCollectors = nixpkgs: inputs: [
    {
      name = "packages";
      path = "packages";
      filter = name: type: type == "directory";
      transform = path: nixpkgs.lib.genAttrs [ "x86_64-linux" ] (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.callPackage path { inherit inputs; });
    }
  ];
  shellCollectors = nixpkgs: inputs: [
    # TODO
  ];
  templateCollectors = nixpkgs: inputs: [
    {
      name = "templates";
      path = "templates";
      filter = name: type: type == "directory";
      transform = name: path: {
        path = path;
        description = "Template for ${path}";
      };
    }
  ];
in
{
  inherit
    nixosCollectors
    homeManagerCollectors
    packageCollectors
    shellCollectors
    templateCollectors;

  defaultCollectors = nixpkgs: inputs:
    (nixosCollectors nixpkgs inputs) ++
    (homeManagerCollectors nixpkgs inputs) ++
    (packageCollectors nixpkgs inputs) ++
    (shellCollectors nixpkgs inputs) ++
    (templateCollectors nixpkgs inputs);

  mkCollector = foo: bar: {
    foo = bar;
  };
}
