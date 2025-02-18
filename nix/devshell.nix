{
  pkgs,
  esp,
  rust,
  zig,
  common,
}:
pkgs.mkShell {
  nativeBuildInputs = common ++ rust ++ zig ++ [esp];

  shellHook = ''
    unset NIX_CFLAGS_COMPILE
    unset NIX_LDFLAGS

    export IDF_PATH=$(pwd)/esp-idf
    export PATH=$IDF_PATH/tools:$PATH
  '';
}
