mod usb;

/// reexports
use std::ptr;
use usb::UsbDevice;

#[no_mangle]
pub extern "C" fn load_usb_devices(count: *mut usize) -> *mut UsbDevice {
    match usb::load_usb_devices() {
        Ok(devices) => {
            unsafe { *count = devices.len() };

            let mut boxed_slice = devices.into_boxed_slice();
            let ptr = boxed_slice.as_mut_ptr();
            std::mem::forget(boxed_slice);

            ptr
        }
        Err(_) => {
            unsafe { *count = 0 };
            ptr::null_mut()
        }
    }
}
