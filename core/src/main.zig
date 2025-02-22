const std = @import("std");
const builtin = @import("builtin");

const os =
    switch (builtin.os.tag) {
    .windows => @import("actions/os/windows/windows.zig"),
    .macos => @import("actions/os/darwin/darwin.zig"),
    .linux, .freebsd, .openbsd => @import("actions/os/posix/posix.zig"),
    else => @compileError("Unsupported OS"),
};

pub fn main() !void {
    std.debug.print("Lets try this out\n\n", .{});

    const a: os.Action = .MuteVolumne;

    switch (a) {
        .IncreaseVolumne => os.volumne.increaseVolume() catch |err| switch (err) {
            os.Error.VolumeChangeError => std.debug.print("Failed to increase volume\n", .{}),
        },

        .DecreaseVolumne => os.volumne.decreaseVolume() catch |err| switch (err) {
            os.Error.VolumeChangeError => std.debug.print("Failed to decrease volume\n", .{}),
        },

        .MuteVolumne => os.volumne.muteVolumne() catch |err| switch (err) {
            os.Error.VolumeChangeError => std.debug.print("Failed to mute volume\n", .{}),
        },
    }
}
