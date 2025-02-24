const std = @import("std");
const builtin = @import("builtin");
const net = std.net;
const mem = std.mem;

const middleware = @import("middleware.zig");

pub const UsbError = error{DeviceNotFound};

pub fn connectToDevice(vendor_id: u16, product_id: u16) UsbError!middleware.UsbDevice {
    var count: usize = 0;
    const devices = middleware.load_usb_devices(&count);

    if (devices == null or count == 0) {
        std.log.warn("No USB devices found.", .{});
        return UsbError.DeviceNotFound;
    }

    var device: ?middleware.UsbDevice = null;
    for (devices.?[0..count]) |raw_device| {
        if (raw_device.vendor_id == vendor_id and raw_device.product_id == product_id) {
            device = raw_device;
            break;
        }
    }

    if (device == null) {
        std.log.warn("taqp device not found in device list", .{});
        return UsbError.DeviceNotFound;
    }

    return device.?;
}
