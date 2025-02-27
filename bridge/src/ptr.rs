use crate::error::{BridgeError, Result};
use std::os::raw::c_void;

type ErrorCode = i32;

/// A helper function to safely dereference a `*const T`.
/// Returns an error code if the pointer is null.
pub fn deref_ptr<'a, T>(ptr: *const T) -> Result<&'a T> {
	if ptr.is_null() {
		return Err(BridgeError::FormatMissmatch);
	}

	unsafe { Ok(&*ptr) }
}

/// A helper function to safely dereference a `*mut T`.
/// Returns an error code if the pointer is null.
pub fn deref_ptr_mut<'a, T>(ptr: *mut T) -> Result<&'a T> {
	if ptr.is_null() {
		return Err(BridgeError::FormatMissmatch);
	}

	unsafe { Ok(&mut *ptr) }
}

/// Safely set `*ptr` to `value`, returning an error if `ptr` is null.
///
/// # Safety
///
/// The caller must ensure that `ptr` points to valid memory for storing
/// a value of type `T`. This function only checks for null.
pub fn set_ptr<T>(ptr: *mut T, value: T) -> Result<()> {
	if ptr.is_null() {
		return Err(BridgeError::FormatMissmatch);
	}

	unsafe {
		*ptr = value;
	}
	Ok(())
}

/// A helper function to safely cast `*mut c_void` to a mutable reference to type `T`.
/// Returns  an error if the pointer is null.
pub fn cast_ptr_mut<'a, T>(ptr: *mut c_void) -> Result<&'a mut T> {
	if ptr.is_null() {
		return Err(BridgeError::FormatMissmatch);
	}
	unsafe { Ok(&mut *(ptr as *mut T)) }
}

/// A helper fucntion to cast `*mut c_void` to an immutable reference to type `T`.
/// Returns an error if the pointer is null.
pub fn cast_ptr<'a, T>(ptr: *mut c_void) -> Result<&'a T> {
	if ptr.is_null() {
		return Err(BridgeError::FormatMissmatch);
	}

	unsafe { Ok(&*(ptr as *const T)) }
}
