use rusb::{
	Device, DeviceDescriptor, DeviceHandle, Direction, TransferType, UsbContext,
};

#[repr(C)]
#[derive(Debug)]
pub struct Endpoint {
	pub config: u8,
	pub iface: u8,
	pub setting: u8,
	pub address: u8,
}

impl Endpoint {
	/// Searches for the first endpoint matching the given transfer type and direction.
	pub fn find_readable<T: UsbContext>(
		device: &mut Device<T>,
		device_desc: &DeviceDescriptor,
		transfer_type: TransferType,
		direction: Direction,
	) -> Option<Endpoint> {
		for n in 0..device_desc.num_configurations() {
			let config_desc = match device.config_descriptor(n) {
				Ok(c) => c,
				Err(_) => continue,
			};

			for interface in config_desc.interfaces() {
				for interface_desc in interface.descriptors() {
					for endpoint_desc in interface_desc.endpoint_descriptors() {
						if endpoint_desc.direction() == direction
							&& endpoint_desc.transfer_type() == transfer_type
						{
							return Some(Endpoint {
								config: config_desc.number(),
								iface: interface_desc.interface_number(),
								setting: interface_desc.setting_number(),
								address: endpoint_desc.address(),
							});
						}
					}
				}
			}
		}

		None
	}

	// If a kernel driver is active for this endpoint’s interface,
	/// detach it so the interface can be claimed by user space.
	fn detach_kernel_driver_if_exists<T: UsbContext>(
		&self,
		handle: &DeviceHandle<T>,
	) {
		match handle.kernel_driver_active(self.iface) {
			Ok(true) => {
				handle.detach_kernel_driver(self.iface).ok();
			}
			_ => {}
		};
	}

	// Configures the device handle by setting the active configuration,
	/// claiming the interface, and setting the alternate interface
	/// if needed for this endpoint.
	pub fn configure<T: UsbContext>(
		&self,
		handle: &mut DeviceHandle<T>,
	) -> Result<(), rusb::Error> {
		self.detach_kernel_driver_if_exists(&handle);

		handle.set_active_configuration(self.config)?;
		handle.claim_interface(self.iface)?;
		handle.set_alternate_setting(self.iface, self.setting)?;
		Ok(())
	}
}
