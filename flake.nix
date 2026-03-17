{
  description = "A flake libary for automatic discovery of outputs";


  outputs = { self, nixpkgs }:
    let
      discovery = import ./lib/discovery.nix;
    in
    {
      lib = discovery;
      templates = {
        nixos = { path = ./templates/nixos; description = "Template for a complete nixos setup"; };
      };
    };
}
