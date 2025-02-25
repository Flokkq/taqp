const builtin = @import("builtin");

pub const os =
    switch (builtin.os.tag) {
    .windows => @import("windows/windows.zig"),
    .macos => @import("darwin/darwin.zig"),
    .linux, .freebsd, .openbsd => @import("posix/posix.zig"),
    else => @compileError("Unsupported OS"),
};
