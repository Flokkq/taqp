mod ptr;
mod usb;

/// reexports
use usb::UsbDevice;
use std::ptr as std_ptr;

#[no_mangle]
pub extern "C" fn load_usb_devices(count: *mut usize) -> *mut UsbDevice {
	match usb::load_usb_devices() {
		Ok(devices) => {
			if let Err(_) = ptr::set_ptr(count, devices.len()) {
				return std_ptr::null_mut();
			}

			let mut boxed_slice = devices.into_boxed_slice();
			let ptr = boxed_slice.as_mut_ptr();
			std::mem::forget(boxed_slice);

			ptr
		}
		Err(_) => {
			let _ = ptr::set_ptr(count, 0);
			std_ptr::null_mut()
		}
	}
}

