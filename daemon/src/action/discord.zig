const std = @import("std");
const net = std.net;
const posix = std.posix;
const Allocator = std.mem.Allocator;

const os = @import("../os.zig");
const action = @import("action.zig");

fn getEnvVar(allocator: Allocator, key: []const u8) ?[]const u8 {
    return std.process.getEnvVarOwned(allocator, key) catch null;
}

pub fn connectToClient() action.ActionError!void {
    const allocator = std.heap.page_allocator;

    const socket_dir = getEnvVar(allocator, "XDG_RUNTIME_DIR") orelse
        getEnvVar(allocator, "TMPDIR") orelse
        getEnvVar(allocator, "TEMP") orelse
        getEnvVar(allocator, "TMP") orelse
        "/tmp";

    defer if (!std.mem.eql(u8, socket_dir, "/tmp")) allocator.free(socket_dir);

    var client_socket_fd: posix.fd_t = -1;
    var found = false;

    for (0..10) |i| {
        const socket_path = std.fmt.allocPrint(allocator, "{s}/discord-ipc-{d}", .{ socket_dir, i }) catch {
            return action.ActionError.ResourceLimitReached;
        };
        defer allocator.free(socket_path);

        client_socket_fd = posix.socket(posix.AF.UNIX, posix.SOCK.STREAM, 0) catch continue;
        defer _ = posix.close(client_socket_fd);

        var sockaddr_un: posix.sockaddr.un = std.mem.zeroes(posix.sockaddr.un);
        const path_len = @min(socket_path.len, sockaddr_un.path.len - 1);
        @memcpy(sockaddr_un.path[0..path_len], socket_path[0..path_len]);

        sockaddr_un.path[path_len] = 0;
        posix.connect(client_socket_fd, @ptrCast(&sockaddr_un), @sizeOf(posix.sockaddr.un)) catch {
            std.log.info("CONNECTED TO: {s}", .{socket_path});
            found = true;
            break;
        };
    }

    if (!found) {
        return action.ActionError.NoAvailableSocket;
    }
}

