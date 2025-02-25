mod bindings;
mod ffi;
mod ptr;
mod usb;

/// reexports
use std::ptr as std_ptr;

use bindings::Action;
use rusb::Context;
use usb::UsbDevice;

#[no_mangle]
pub extern "C" fn connect(vendor_id: u16, product_id: u16) -> *mut UsbDevice {
	let mut context = match Context::new() {
		Ok(c) => c,
		Err(_) => return std_ptr::null_mut(),
	};

	match UsbDevice::connect(&mut context, vendor_id, product_id) {
		Ok(device) => {
			let boxed = Box::new(device);
			Box::into_raw(boxed)
		}
		Err(_) => std_ptr::null_mut(),
	}
}

#[no_mangle]
pub extern "C" fn send_to_device(device: *mut UsbDevice, action: u8) -> i32 {
	let device = try_unwrap!(ptr::deref_ptr_mut(device));
	let action: Action = try_unwrap!(action.try_into());

	match device.send_action(action) {
		Ok(_) => 0,
		// TODO: proper error handlling
		Err(_) => -3,
	}
}
