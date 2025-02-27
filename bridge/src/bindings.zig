pub extern fn connect(vendor_id: u16, product_id: u16, out_device: *?*UsbDevice) i32;
pub extern fn send_to_device(device: *UsbDevice, action: u8) i32;
pub extern fn read_from_device(device: *UsbDevice, out_message: *?*WireMessage) i32;

pub const UsbDevice = extern struct {
    vendor_id: u16,
    product_id: u16,

    endpoint_in: Endpoint,
    endpoint_out: Endpoint,

    handle_ptr: ?*anyopaque,
};

pub const Endpoint = extern struct {
    config: u8,
    iface: i8,
    setting: u8,
    address: u8,
};

pub const WireMessage = extern struct {
    tag: MessageTag,
    data: [*]const u8,
};

pub const MessageTag = u8;
pub const MESSAGE_TAG_EXECUTE_ACTION: MessageTag = 1;
pub const MESSAGE_TAG_CONFIG: MessageTag = 2;

pub const BridgeError = i32;
pub const BRIDGE_ERROR_CONNECTION = -1; // Device disconnected or unavailable
pub const BRIDGE_ERROR_READ_ERROR = -2; // Failed to read from device
pub const BRIDGE_ERROR_WRITE_ERROR = -3; // Failed to write to device
pub const BRIDGE_ERROR_FORMAT_MISSMATCH = -4; // Expected input to be in different format (cast error)
pub const BRIDGE_ERROR_UNDEFINED = -5; // Unexpected behaviour
