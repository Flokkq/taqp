const std = @import("std");
const builtin = @import("builtin");
const action = @import("action/action.zig");
const net = std.net;
const mem = std.mem;

const ipc = @import("ipc.zig");
const usb = @import("usb.zig");
const bindings = @import("bindings");

pub fn main() !void {
    const vendor_id: u16 = 0x10c4;
    const product_id: u16 = 0xea60;

    const thread = try std.Thread.spawn(.{}, struct {
        pub fn run() !void {
            while (true) {
                const device = usb.connectToDevice(vendor_id, product_id) catch |err| {
                    std.log.err("Failed connecting to taqp device: {}", .{err});
                    std.time.sleep(1_000_000_000);
                    continue;
                };

                std.log.info("Found taqp device: {d}-{d}", .{ vendor_id, product_id });

                while (true) {
                    const message = usb.readFromDevice(device) catch |err| {
                        std.log.err("Error reading from device: {}", .{err});

                        // If we loose connection leave the inner loop to try
                        // and poll a new connection.
                        switch (err) {
                            usb.UsbError.ConnectionLost => break,
                            else => continue,
                        }
                    };

                    std.log.info("Recieved message from device: {any}", .{message});

                    usb.handleClient(message) catch |err| {
                        std.log.err("Error processing message: {}", .{err});
                    };
                }
            }
        }
    }.run, .{});
    thread.detach();

    const addr = net.Address.initIp4(.{ 127, 0, 0, 1 }, 18769);
    var server = try addr.listen(.{});

    std.log.info("listening at {}", .{server.listen_address});

    while (true) {
        const connection = server.accept() catch |err| {
            std.log.err("Error reading from socket: {}", .{err});
            continue;
        };

        std.log.info("connected to {}\n", .{connection.address});

        ipc.handleClient(connection.stream) catch |err| {
            std.log.err("Error processing connection: {}", .{err});
        };
    }
}
