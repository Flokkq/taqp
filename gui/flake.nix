{
  description = "Flake providing prebuilt Mach-specific Zig compiler for macOS (aarch64) and Linux (x86_64)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachSystem ["aarch64-darwin" "x86_64-linux"] (system: let
      pkgs = import nixpkgs {inherit system;};

      zig_mach_info = {
        "aarch64-darwin" = {
          url = "https://pkg.machengine.org/zig/zig-macos-aarch64-0.14.0-dev.2577+271452d22.tar.xz";
          sha256 = "sha256-A005UlbZ+Ln06fsHvDQoM2tROIU9wtUYiY+g+o+rQ08=";
        };
        "x86_64-linux" = {
          url = "https://pkg.machengine.org/zig/zig-linux-x86_64-0.14.0-dev.2577+271452d22.tar.xz";
          sha256 = "sha256-13cc3np2y18f1jr1rrriylb4zs340j6k8nqnil9wcw59pzgaprkv";
        };
      };

      zig_mach = pkgs.stdenv.mkDerivation {
        pname = "zig-mach";
        version = "0.14.0-dev";
        src = pkgs.fetchurl {
          url = zig_mach_info.${system}.url;
          sha256 = zig_mach_info.${system}.sha256;
        };

        buildInputs = [pkgs.patchelf];
        unpackPhase = "tar -xf $src";
        installPhase = ''
          mkdir -p $out/bin
          cp -r zig-*/* $out/
          mv $out/zig $out/bin/zig
        '';
      };
    in {
      packages.default = zig_mach;
      devShells.default = pkgs.mkShell {
        buildInputs = [zig_mach];
        shellHook = ''
          export PATH="$PATH:${zig_mach}/bin"
          echo "Using Mach's Zig: $(zig version)"
        '';
      };
    });
}
