use rusb::{Device, GlobalContext};

#[repr(C)]
pub struct UsbDevice {
    bus: u8,
    address: u8,
    vendor_id: u16,
    product_id: u16,
}

impl UsbDevice {
    pub fn send<T: serde::Serialize>(&self, _data: T) -> Result<(), rusb::Error> {
        Ok(())
    }
}

impl TryFrom<Device<GlobalContext>> for UsbDevice {
    type Error = rusb::Error;

    fn try_from(value: Device<GlobalContext>) -> Result<Self, Self::Error> {
        let device_desctiption = value.device_descriptor()?;

        let device = UsbDevice {
            bus: value.bus_number(),
            address: value.address(),
            vendor_id: device_desctiption.vendor_id(),
            product_id: device_desctiption.product_id(),
        };

        Ok(device)
    }
}

/// Returns a list of all connected usb devices on the machine. Returns [`rusb::Error::NotFound`]
/// if no devices are connected.
pub fn load_usb_devices() -> Result<Vec<UsbDevice>, rusb::Error> {
    let mut devices = Vec::new();
    let raw_devices = rusb::devices()?;

    if raw_devices.is_empty() {
        return Err(rusb::Error::NotFound);
    }

    for device in raw_devices.iter() {
        devices.push(UsbDevice::try_from(device)?);
    }

    Ok(devices)
}
