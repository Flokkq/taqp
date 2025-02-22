const std = @import("std");
const builtin = @import("builtin");

const os =
    switch (builtin.os.tag) {
    .windows => @import("actions/os/windows/windows.zig"),
    .macos => @import("actions/os/darwin/darwin.zig"),
    .linux, .freebsd, .openbsd => @import("actions/os/posix/posix.zig"),
    else => @compileError("Unsupported OS"),
};

const OsError = @import("actions/os/error.zig").OsError;

pub fn main() !void {
    std.debug.print("Lets try this out\n\n", .{});

    os.volumne.increase_volume() catch |err| switch (err) {
        OsError.VolumeChangeError => std.debug.print("Failed to increase volume\n", .{}),
    };

    os.volumne.decrease_volume() catch |err| switch (err) {
        OsError.VolumeChangeError => std.debug.print("Failed to decrease volume\n", .{}),
    };

    os.volumne.mute_volumne() catch |err| switch (err) {
        OsError.VolumeChangeError => std.debug.print("Failed to mute volume\n", .{}),
    };
}
