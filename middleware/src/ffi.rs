/// Safely unwraps a `Result`, returning from the enclosing function on error.
///
/// This macro is useful in FFI-style functions that return an integer error code.
/// If `$expr` evaluates to `Ok(val)`, it yields `val`.
/// If `$expr` evaluates to `Err(err_code)`, it immediately returns `err_code` from
/// the *enclosing* function (so the enclosing function must return a compatible type).
///
/// This approach avoids panics across FFI boundaries by returning an integer error code instead.
#[macro_export]
macro_rules! try_unwrap {
	($expr:expr) => {
		match $expr {
			Ok(val) => val,
			Err(err_code) => return err_code,
		}
	};
}
