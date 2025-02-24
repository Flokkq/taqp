type ErrorCode = i32;

/// Safely set `*ptr` to `value`, returning an error if `ptr` is null.
///
/// # Safety
///
/// The caller must ensure that `ptr` points to valid memory for storing
/// a value of type `T`. This function only checks for null.
pub fn set_ptr<T>(ptr: *mut T, value: T) -> Result<(), ErrorCode> {
	if ptr.is_null() {
		return Err(-1);
	}

	unsafe {
		*ptr = value;
	}
	Ok(())
}
