const std = @import("std");
const builtin = @import("builtin");
const net = std.net;
const mem = std.mem;

const action = @import("action/action.zig");

pub const IpcError = error{ ChunkSize, InvalidInput, ActionError };

pub fn handleClient(connection: net.Stream) IpcError!void {
    var buffer: [1]u8 = undefined;

    const bytes_read = connection.readAll(&buffer) catch |err| {
        std.log.err("Read error: {}", .{err});
        return IpcError.ChunkSize;
    };

    if (bytes_read != 1) {
        std.log.err("Expected 1 byte but got {d}", .{bytes_read});
        return IpcError.ChunkSize;
    }

    const action_value: u8 = mem.readInt(u8, &buffer, .big);
    const axn = action.Action.from_int(action_value) orelse {
        std.log.err("Invalid action value: {d}", .{action_value});
        return IpcError.InvalidInput;
    };

    action.execute(axn) catch |err| {
        std.log.err("Error executing action: {}", .{err});
        return IpcError.ActionError;
    };
}
