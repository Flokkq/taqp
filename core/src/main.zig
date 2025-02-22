const std = @import("std");
const builtin = @import("builtin");

const os =
    switch (builtin.os.tag) {
    .windows => @import("actions/os/windows.zig"),
    .macos => @import("actions/os/darwin.zig"),
    .linux, .freebsd, .openbsd => @import("actions/os/posix.zig"),
    else => @compileError("Unsupported OS"),
};

const OsError = @import("actions/os/error.zig").OsError;

pub fn main() !void {
    std.debug.print("Lets try this out\n\n", .{});

    os.increase_volume() catch |err| switch (err) {
        OsError.VolumeChangeError => std.debug.print("Failed to increase volume\n", .{}),
    };

    os.decrease_volume() catch |err| switch (err) {
        OsError.VolumeChangeError => std.debug.print("Failed to decrease volume\n", .{}),
    };
}
