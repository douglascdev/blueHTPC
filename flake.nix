{
  description = "Development environment for blueHTPC";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bluebuild.url = "https://flakehub.com/f/blue-build/cli/0.9.37";
    bluebuild.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, bluebuild, }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Task runner
            just
            bluebuild.packages.${system}.bluebuild

            # Shell
            bash

            # Container tools
            podman
            buildah
            skopeo

            # Linting and formatting
            shellcheck
            shfmt
            findutils

            # Utilities
            jq
            git
          ];

          shellHook = ''
            echo "blueHTPC dev shell"
            echo "Run 'just --list' to see available commands"
          '';
        };
      });
}
