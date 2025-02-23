{
  pkgs,
  # esp,
  rust,
  zig,
  common,
}: let
  builtInputs =
    common ++ rust ++ zig
    /*
    ++ esp
    */
    ;
in
  pkgs.mkShell {
    nativeBuildInputs = builtInputs;

    shellHook = ''
      unset NIX_CFLAGS_COMPILE
      unset NIX_LDFLAGS

      export IDF_PATH=$(pwd)/esp-idf
      export PATH=$IDF_PATH/tools:$PATH

      export LIBRARY_PATH="${pkgs.lib.makeLibraryPath builtInputs}"
      export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath builtInputs}"
    '';
  }
