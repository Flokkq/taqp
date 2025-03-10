use rusb::{Context, DeviceHandle, UsbContext};

use super::endpoint::Endpoint;
use crate::{
	error::{BridgeError, Result},
	ptr,
};

#[repr(C)]
#[derive(Debug)]
pub struct UsbDevice {
	vendor_id: u16,
	product_id: u16,

	endpoint_in: Endpoint,
	endpoint_out: Endpoint,

	// This pointer is how we store the handle.
	// We only use it internally in Rust, but it must be declared
	// so that Rust & Zig agree on the size of the struct.
	handle_ptr: *mut core::ffi::c_void,
}

impl UsbDevice {
	const TIMEOUT: std::time::Duration = std::time::Duration::from_millis(1000);

	/// Finds and opens the device matching the `vendor_id` and `product_id`, then
	/// discovers and configures bulk IN/OUT endpoints.
	pub fn connect<T: UsbContext>(
		context: &mut T,
		vid: u16,
		pid: u16,
	) -> Result<UsbDevice> {
		let devices = context.devices().map_err(|_| BridgeError::Connection)?;

		for mut device in devices.iter() {
			let device_desc = match device.device_descriptor() {
				Ok(d) => d,
				Err(_) => continue,
			};

			if device_desc.vendor_id() == vid && device_desc.product_id() == pid
			{
				let endpoint_in = match Endpoint::find_readable(
					&mut device,
					&device_desc,
					rusb::TransferType::Bulk,
					rusb::Direction::In,
				) {
					Some(e) => e,
					None => return Err(BridgeError::Connection),
				};

				let endpoint_out = match Endpoint::find_readable(
					&mut device,
					&device_desc,
					rusb::TransferType::Bulk,
					rusb::Direction::Out,
				) {
					Some(e) => e,
					None => return Err(BridgeError::Connection),
				};

				let mut handle =
					device.open().map_err(|_| BridgeError::Connection)?;

				endpoint_in
					.configure(&mut handle)
					.map_err(|_| BridgeError::Connection)?;

				endpoint_out
					.configure(&mut handle)
					.map_err(|_| BridgeError::Connection)?;

				let handle_boxed = Box::new(handle);
				let handle_ptr =
					Box::into_raw(handle_boxed) as *mut core::ffi::c_void;

				return Ok(Self {
					vendor_id: vid,
					product_id: pid,
					endpoint_in,
					endpoint_out,
					handle_ptr,
				});
			}

			return Err(BridgeError::Connection);
		}

		return Err(BridgeError::Connection);
	}

	fn send<T: serde::Serialize>(&self, data: T) -> Result<()> {
		let serialized =
			bincode::serialize(&data).map_err(|_| BridgeError::WriteError)?;

		self.handle()
			.map_err(BridgeError::from)?
			.write_bulk(self.endpoint_out.address, &serialized, Self::TIMEOUT)
			.map_err(BridgeError::from)?;

		Ok(())
	}

	/// Reads and deserializes a [`Message`] from the device’s IN endpoint.
	pub fn recieve(&self) -> Result<Message> {
		let mut buffer = [0u8; 1024];

		let size = self
			.handle()
			.map_err(BridgeError::from)?
			.read_bulk(self.endpoint_in.address, &mut buffer, Self::TIMEOUT)
			.map_err(BridgeError::from)?;

		bincode::deserialize(&buffer[..size])
			.map_err(|_| BridgeError::ReadError)
	}

	/// Sends an [`Action`] to the device over the OUT endpoint.
	pub fn send_action(&self, action: Action) -> Result<()> {
		self.send(action)
	}

	/// Sends a [`TaqpConfig`] to the device over the OUT endpoint.
	pub fn send_config(&self, config: TaqpConfig) -> Result<()> {
		self.send(config)
	}

	pub fn handle(&self) -> Result<&DeviceHandle<Context>> {
		ptr::cast_ptr::<DeviceHandle<Context>>(self.handle_ptr)
			.map_err(BridgeError::from)
	}
}

#[derive(Debug, serde::Serialize, serde::Deserialize)]
pub struct TaqpConfig {
	keybinds: Vec<Vec<Action>>,
}

#[derive(Debug, serde::Serialize, serde::Deserialize)]
pub enum Message {
	ExecuteAction(Action),
	Config(TaqpConfig),
}

#[repr(u8)]
#[derive(Debug, serde::Serialize, serde::Deserialize)]
pub enum Action {
	MuteVolume,
	IncreaseVolume,
	DecreaseVolume,
	Ignore,
}

impl TryFrom<u8> for Action {
	type Error = BridgeError;

	fn try_from(value: u8) -> std::result::Result<Self, Self::Error> {
		match value {
			x if x == Self::MuteVolume as u8 => Ok(Self::MuteVolume),
			x if x == Self::IncreaseVolume as u8 => Ok(Self::IncreaseVolume),
			x if x == Self::DecreaseVolume as u8 => Ok(Self::DecreaseVolume),
			x if x == Self::Ignore as u8 => Ok(Self::Ignore),
			_ => Err(BridgeError::FormatMissmatch),
		}
	}
}

impl From<Action> for u8 {
	fn from(action: Action) -> Self {
		action as u8
	}
}
