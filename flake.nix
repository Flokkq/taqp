{
  description = "A basic flake for Rust, Zig, and ESP32 development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};

      esp = import ./nix/esp {inherit pkgs;};
      rust = import ./nix/rust.nix {inherit pkgs;};
      zig = import ./nix/zig.nix {inherit pkgs;};
      common = import ./nix/common.nix {inherit pkgs;};
    in {
      devShells.default = import ./nix/devshell.nix {
        inherit pkgs esp rust zig common;
      };
    });
}
