{
  description = "particle boron dev-board";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    gcc-10-2-1-pkgs.url = "github:NixOS/nixpkgs/d66917c4df5addb334a761d8e1e4279105e8c9ac";
    jix.url = "github:ttrssreal/jix";
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs = {
    nixpkgs,
    jix,
    flake-utils,
    gcc-10-2-1-pkgs,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (jix.packages.${system}) particle-cli;

        boron-platform = pkgs.pkgsCross.arm-embedded;
        gcc-10-2-1 = gcc-10-2-1-pkgs.legacyPackages.x86_64-linux.gcc-arm-embedded-10;

        buildBoronApp = name: src: pkgs.callPackage ./build-boron-app.nix {
          inherit
            boron-platform
            gcc-10-2-1
            src
            name
            ;
        };

        blink-led = buildBoronApp "blink-led" ./blink-led;
      in {
        packages = {
          inherit blink-led;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            bashInteractive
            particle-cli
          ];
        };
      }
    );
}
