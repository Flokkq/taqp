const std = @import("std");
const builtin = @import("builtin");
const net = std.net;

const ipc = @import("ipc.zig");

pub fn main() !void {
    const addr = net.Address.initIp4(.{ 127, 0, 0, 1 }, 18769);
    var server = try addr.listen(.{});

    std.log.info("listening at {}\n", .{server.listen_address});

    while (true) {
        const connection = try server.accept();
        std.log.info("connected to {}\n", .{connection.address});

        ipc.handleClient(connection.stream) catch |err| {
            std.log.err("Error processing connection: {}\n", .{err});
        };
    }
}
