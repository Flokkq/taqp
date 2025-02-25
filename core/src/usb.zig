const std = @import("std");
const builtin = @import("builtin");
const net = std.net;
const mem = std.mem;

const middleware = @import("middleware.zig");
const Action = @import("action/action.zig").Action;

pub const UsbError = error{ DeviceNotFound, SendFailure, ReadFailure };

pub fn connectToDevice(vendor_id: u16, product_id: u16) UsbError!*middleware.UsbDevice {
    const device = middleware.connect(vendor_id, product_id);

    if (device == null) {
        std.log.warn("taqp device not found in device list", .{});
        return UsbError.DeviceNotFound;
    }

    return device.?;
}

pub fn sendToDevice(device: *middleware.UsbDevice, action: Action) UsbError!void {
    const action_byte: u8 = @intFromEnum(action);
    const result = middleware.send_to_device(device, action_byte);

    if (result < 0) {
        std.log.err("Failed sending data to device", .{});
        return UsbError.SendFailure;
    }

    return;
}

pub fn readFromDevice(device: *middleware.UsbDevice) UsbError!*middleware.WireMessage {
    const message = middleware.read_from_device(device);

    if (message == null) {
        std.log.warn("Failed reading data from device", .{});
        return UsbError.ReadFailure;
    }

    return message.?;
}
