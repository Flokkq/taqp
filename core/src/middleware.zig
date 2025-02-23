pub extern fn load_usb_devices(count: *usize) callconv(.C) ?[*]UsbDevice;

const UsbDevice = struct {
    bus: u8,
    address: u8,
    vendor_id: u16,
    product_id: u16,
};
