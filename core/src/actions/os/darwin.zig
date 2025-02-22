const std = @import("std");

pub fn hello_from_darwin() void {
    std.debug.print("Hello from darwin", .{});
}
