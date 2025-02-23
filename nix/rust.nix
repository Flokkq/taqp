{pkgs}:
with pkgs;
  [
    rustc
    cargo
    rust-analyzer
    clippy
    rustfmt

    libusb
    libiconv
  ]
  ++ pkgs.lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.IOKit
    darwin.apple_sdk.frameworks.SystemConfiguration
  ]
