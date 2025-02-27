const std = @import("std");
const builtin = @import("builtin");
const action = @import("action/action.zig");
const net = std.net;
const mem = std.mem;

const bindings = @import("bindings");
const Action = @import("action/action.zig").Action;

pub const UsbError = error{
    DeviceNotFound,
    SendFailure,
    ReadFailure,
    ConnectionLost,
    InvalidInput,
    ActionError,
    Unknown,
};

fn bridgeErrorToUsbError(err: bindings.BridgeError) UsbError {
    return switch (err) {
        0 => unreachable,
        bindings.BRIDGE_ERROR_CONNECTION => UsbError.ConnectionLost,
        bindings.BRIDGE_ERROR_READ_ERROR => UsbError.ReadFailure,
        bindings.BRIDGE_ERROR_WRITE_ERROR => UsbError.SendFailure,
        bindings.BRIDGE_ERROR_FORMAT_MISSMATCH => UsbError.InvalidInput,
        else => UsbError.Unknown,
    };
}

pub fn connectToDevice(vendor_id: u16, product_id: u16) UsbError!*bindings.UsbDevice {
    var device: ?*bindings.UsbDevice = null;
    const result = bindings.connect(vendor_id, product_id, &device);

    if (result < 0) {
        const err = bridgeErrorToUsbError(result);
        std.log.err("Failed to connect to device: error code {}", .{err});
        return err;
    }

    return device.?;
}

pub fn sendToDevice(device: *bindings.UsbDevice, axn: Action) UsbError!void {
    const action_byte: u8 = @intFromEnum(axn);
    const result = bindings.send_to_device(device, action_byte);

    if (result < 0) {
        const err = bridgeErrorToUsbError(result);
        std.log.err("Failed sending action '{}' to device: {}", .{ axn, err });
        return err;
    }

    std.log.info("Sent action {} to device successfully", .{axn});
}

pub fn readFromDevice(device: *bindings.UsbDevice) UsbError!*bindings.WireMessage {
    var message: ?*bindings.WireMessage = null;
    const result: bindings.BridgeError = bindings.read_from_device(device, &message);

    if (result < 0) {
        const err = bridgeErrorToUsbError(result);
        std.log.warn("Failed reading data from device: {}", .{err});
        return err;
    }

    return message.?;
}

pub fn handleClient(message: *bindings.WireMessage) UsbError!void {
    if (message.tag != bindings.MESSAGE_TAG_EXECUTE_ACTION) {
        std.log.warn("Recieved invalid message tag: {}", .{message.tag});
        return UsbError.InvalidInput;
    }

    // TODO: add `len` attribute to wiremessage
    const action_value: u8 = mem.readInt(u8, message.data[0..1], .big);
    const axn = action.Action.from_int(action_value) orelse {
        std.log.err("Invalid action value: {d}", .{action_value});
        return UsbError.InvalidInput;
    };

    action.execute(axn) catch |err| {
        std.log.err("Error executing action: {}", .{err});
        return UsbError.ActionError;
    };
}
