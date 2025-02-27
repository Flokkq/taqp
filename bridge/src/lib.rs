mod bindings;
mod error;
mod ptr;
mod usb;

/// reexports
use std::ptr as std_ptr;

use crate::bindings::WireMessage;
use error::BridgeError;
use rusb::Context;
use usb::{Action, UsbDevice};

#[no_mangle]
pub extern "C" fn connect(
	vendor_id: u16,
	product_id: u16,
	out_device: *mut *mut UsbDevice,
) -> i32 {
	if out_device.is_null() {
		return BridgeError::FormatMissmatch.into();
	}

	let mut context = match Context::new() {
		Ok(c) => c,
		Err(_) => return BridgeError::Connection.into(),
	};

	match UsbDevice::connect(&mut context, vendor_id, product_id) {
		Ok(device) => {
			let boxed = Box::new(device);
			unsafe {
				*out_device = Box::into_raw(boxed);
			}
			0
		}
		Err(err) => err.into(),
	}
}

#[no_mangle]
pub extern "C" fn send_to_device(device: *mut UsbDevice, action: u8) -> i32 {
	let device = try_unwrap!(ptr::deref_ptr_mut(device));
	let action: Action = try_unwrap!(action.try_into());

	match device.send_action(action) {
		Ok(_) => 0,
		Err(err) => err.into(),
	}
}

#[no_mangle]
pub extern "C" fn read_from_device(
	device: *mut UsbDevice,
	out_message: *mut *mut WireMessage,
) -> i32 {
	if out_message.is_null() {
		return BridgeError::FormatMissmatch.into();
	}

	let device = try_unwrap!(ptr::deref_ptr_mut(device));
	match device.recieve() {
		Ok(message) => {
			let wire_message = WireMessage::from(message);
			let boxed = Box::new(wire_message);
			unsafe {
				*out_message = Box::into_raw(boxed);
			}
			0
		}
		Err(err) => err.into(),
	}
}
