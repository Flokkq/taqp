const std = @import("std");
const builtin = @import("builtin");

const os =
    switch (builtin.os.tag) {
    .windows => @import("actions/os/windows.zig"),
    .macos => @import("actions/os/darwin.zig"),
    .linux, .freebsd, .openbsd => @import("actions/os/posix.zig"),
    else => @compileError("Unsupported OS"),
};

pub fn main() !void {
    std.debug.print("Lets try this out\n\n", .{});
    os.hello();
}
