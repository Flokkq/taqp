const builtin = @import("builtin");

pub const current_os: SupportedOS =
    switch (builtin.os.tag) {
    .windows => .Windwos,
    .macos => .Macos,
    .linux, .freebsd, .openbsd => .Posix,
    else => @compileError("Unsupported OS"),
};

pub const SupportedOS = enum { Windows, Macos, Posix };
