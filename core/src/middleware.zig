pub extern fn connect(vendor_id: u16, product_id: u16) ?*UsbDevice;
pub extern fn send_to_device(device: *UsbDevice, action: u8) i32;

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
