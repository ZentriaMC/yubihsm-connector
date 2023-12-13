{
  description = "yubihsm-connector";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    clean-devshell.url = "github:ZentriaMC/clean-devshell";
  };

  outputs = { self, nixpkgs, flake-utils, clean-devshell, ... }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    flake-utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        mkShell = pkgs.callPackage clean-devshell.lib.mkDevShell { };
      in
      rec {
        packages.yubihsm-connector = pkgs.callPackage
          ({ buildGoModule, lib, pkg-config, libusb }: buildGoModule rec {
            pname = "yubihsm-connector";
            version = self.rev or "dirty";

            src = lib.cleanSource ./.;

            vendorHash = "sha256-+z+w96GRUAN/6GWnpPET75bdvsBh8yA+jK/ENajRL/o=";
            subPackages = [ "." ];

            nativeBuildInputs = [
              pkg-config
            ];

            buildInputs = [
              libusb
            ];

            preBuild = ''
              make gen
            '';
          })
          { };
      });
}
