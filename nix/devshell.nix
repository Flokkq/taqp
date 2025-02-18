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
    export ESP_IDF_TOOLS_PATH=$HOME/.espressif
  '';
}
