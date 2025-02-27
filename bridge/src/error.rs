use std::{error::Error, fmt::Display, result};

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
			Err(err) => return err.into(),
		}
	};
}

#[repr(i32)]
#[derive(Debug)]
pub enum BridgeError {
	/// Device disconnected or unavailable
	Connection = -1,

	/// Failed to read from device
	ReadError = -2,

	/// Failed to write to device
	WriteError = -3,

	/// Expected input to be in different format (cast error)
	FormatMissmatch = -4,

	/// Unexpected behaviour
	Undefined = -5,
}

impl Display for BridgeError {
	fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
		writeln!(f, "{}\n", self)?;
		Ok(())
	}
}

impl Error for BridgeError {
	fn source(&self) -> Option<&(dyn Error + 'static)> {
		None
	}

	fn description(&self) -> &str {
		"description() is deprecated; use Display"
	}

	fn cause(&self) -> Option<&dyn Error> {
		self.source()
	}
}

impl From<i32> for BridgeError {
	fn from(value: i32) -> Self {
		match value {
			-1 => BridgeError::Connection,
			-2 => BridgeError::ReadError,
			-3 => BridgeError::WriteError,
			-4 => BridgeError::FormatMissmatch,
			_ => BridgeError::Undefined,
		}
	}
}

impl Into<i32> for BridgeError {
	fn into(self) -> i32 {
		self as i32
	}
}

impl From<rusb::Error> for BridgeError {
	fn from(err: rusb::Error) -> Self {
		match err {
			rusb::Error::NotSupported
			| rusb::Error::BadDescriptor
			| rusb::Error::NoDevice
			| rusb::Error::NotFound => BridgeError::Connection,

			rusb::Error::Io | rusb::Error::Pipe | rusb::Error::Interrupted => {
				BridgeError::ReadError
			}

			rusb::Error::InvalidParam
			| rusb::Error::Access
			| rusb::Error::Busy => BridgeError::WriteError,

			rusb::Error::Timeout | rusb::Error::Overflow => {
				BridgeError::FormatMissmatch
			}

			rusb::Error::NoMem | rusb::Error::Other => BridgeError::Undefined,
		}
	}
}

pub type Result<T> = result::Result<T, BridgeError>;
