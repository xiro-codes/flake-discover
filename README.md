# flake-discover

`flake-discover` is a Nix flake library for automatically discovering and structuring your Nix flake outputs based on your repository's directory tree.

Instead of manually wiring up `nixosConfigurations`, `packages`, `devShells`, and `homeConfigurations` in your `flake.nix`, `flake-discover` crawls your folder structure and maps directories to standard Nix flake outputs using customizable "collectors".

## Features

- **Zero-Boilerplate Flakes**: Organize your code into standard directories and let `flake-discover` generate the outputs.
- **Default Collectors**: Built-in support for NixOS systems, Home Manager configurations, packages, development shells, and templates.
- **Customizable**: Extend discovery logic by writing custom collectors for any flake output type.
- **Template Included**: Comes with a ready-to-use boilerplate for NixOS & Home Manager.

## Installation

Add `flake-discover` to your flake inputs:

```nix
{
  description = "My system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-discover.url = "github:xiro-codes/flake-discover";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, flake-discover, ... }@inputs: 
    let
      discovered = flake-discover.lib.discover {
        root = ./.;
        collectors = flake-discover.lib.collectors.defaultCollectors nixpkgs inputs;
      };
    in
    {
      inherit (discovered)
        nixosConfigurations
        homeConfigurations
        nixosModules
        homeModules
        packages
        templates
        devShells;
    };
}
```

## Directory Structure

When using `defaultCollectors`, `flake-discover` expects the following directory structure in your repository:

| Directory | Output Type | Description |
|-----------|-------------|-------------|
| `systems/<name>/configuration.nix` | `nixosConfigurations` | Discovers NixOS systems. Automatically processed with `nixpkgs.lib.nixosSystem`. |
| `modules/system/<name>/` | `nixosModules` | Discovers system-wide NixOS modules. |
| `home/<name>.nix` | `homeConfigurations` | Discovers Home Manager configs. Automatically processed with `homeManagerConfiguration`. |
| `modules/home/<name>/` | `homeModules` | Discovers Home Manager modules. |
| `packages/<name>/` | `packages` | Discovers custom packages. Processed with `pkgs.callPackage` for supported systems. |
| `shells/<name>/` | `devShells` | Discovers development shells. Processed with `pkgs.callPackage` for supported systems. |
| `templates/<name>/` | `templates` | Discovers flake templates. |

### Note on Recursion
To avoid infinite recursion loops during flake evaluation, `flake-discover` ignores any `default.nix` file it encounters while recursively crawling directories.

## Advanced Usage: Custom Collectors

You can define custom rules for how directories map to outputs by creating your own collectors using `flake-discover.lib.collectors.mkCollector`.

```nix
let
  myCustomCollector = flake-discover.lib.collectors.mkCollector {
    name = "myOutputs";
    path = "custom-folder";
    filter = name: type: type == "directory"; # Only match directories
    transform = path: import path; # How to load the discovered path
  };
in
flake-discover.lib.discover {
  root = ./.;
  collectors = [ myCustomCollector ];
}
```

## Templates

You can quickly scaffold a new configuration using the included template:

```bash
nix flake init -t github:xiro-codes/flake-discover#default
```

This will generate a complete boilerplate structure for managing NixOS configurations, Home Manager profiles, custom modules, packages, and shells.
