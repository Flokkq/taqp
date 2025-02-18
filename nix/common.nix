{pkgs}:
with pkgs; [
  git
  gnupg
  pre-commit
  pkg-config
  llvmPackages.bintools
  lldb
  gcc
  cmake
  llvmPackages_19.clang-tools
]
