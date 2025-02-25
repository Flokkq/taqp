pub extern fn connect(vendor_id: u16, product_id: u16) ?*UsbDevice;
pub extern fn send_to_device(device: *UsbDevice, action: u8) i32;
pub extern fn read_from_device(device: *UsbDevice) ?*WireMessage;

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
