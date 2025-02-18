{pkgs}:
with pkgs; [
  (pkgs.callPackage ./esp-idf.nix {})
  espflash
]
