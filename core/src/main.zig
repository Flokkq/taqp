const std = @import("std");
const builtin = @import("builtin");
const net = std.net;

const ipc = @import("ipc.zig");
const usb = @import("usb.zig");
const middleware = @import("middleware.zig");

pub fn main() !void {
    const addr = net.Address.initIp4(.{ 127, 0, 0, 1 }, 18769);
    var server = try addr.listen(.{});

    std.log.info("listening at {}", .{server.listen_address});

    const vendor_id: u16 = 0x10c4;
    const product_id: u16 = 0xea60;
    const device = usb.connectToDevice(vendor_id, product_id) catch |err| {
        std.log.err("Failed connecting to taqp device: {}", .{err});
        return;
    };

    std.log.info("Found taqp device: {?}", .{device});

    usb.sendToDevice(device, .MuteVolume) catch |err| {
        std.log.err("Failed sending data to device: {}", .{err});
        return;
    };

    while (true) {
        const connection = try server.accept();
        std.log.info("connected to {}\n", .{connection.address});

        ipc.handleClient(connection.stream) catch |err| {
            std.log.err("Error processing connection: {}", .{err});
        };
    }
}
