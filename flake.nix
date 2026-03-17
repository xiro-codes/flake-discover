{
  description = "A flake libary for automatic discovery of outputs";


  outputs = { self, nixpkgs }:
    let
      discovery = import ./lib/discovery.nix;
      collectors = import ./lib/collectors.nix;
    in
    {
      lib = {
        inherit (discovery) discover;
        inherit collectors;
      };
      templates = {
        default = { path = ./templates/nixos; description = "Template for a complete nixos setup"; };
      };
    };
}
