use crate::usb::{Action, Message, TaqpConfig};

#[repr(u8)]
pub enum MessageTag {
	ExecuteAction = 1,
	Config = 2,
}

#[repr(C)]
pub struct WireMessage {
	tag: MessageTag,
	data: Vec<u8>,
}

impl From<Message> for WireMessage {
	fn from(msg: Message) -> Self {
		match msg {
			Message::ExecuteAction(action) => WireMessage {
				tag: MessageTag::ExecuteAction,
				data: bincode::serialize(&action).unwrap_or_default(),
			},
			Message::Config(config) => WireMessage {
				tag: MessageTag::Config,
				data: bincode::serialize(&config).unwrap_or_default(),
			},
		}
	}
}

impl TryFrom<WireMessage> for Message {
	type Error = i32;

	fn try_from(wire: WireMessage) -> Result<Self, Self::Error> {
		match wire.tag {
			MessageTag::ExecuteAction => {
				let action: Action =
					bincode::deserialize(&wire.data).map_err(|_| -7)?;
				Ok(Message::ExecuteAction(action))
			}
			MessageTag::Config => {
				let config: TaqpConfig =
					bincode::deserialize(&wire.data).map_err(|_| -8)?;
				Ok(Message::Config(config))
			}
		}
	}
}

impl From<MessageTag> for u8 {
	fn from(tag: MessageTag) -> Self {
		tag as u8
	}
}

impl TryFrom<u8> for MessageTag {
	type Error = i32;

	fn try_from(value: u8) -> Result<Self, Self::Error> {
		match value {
			x if x == MessageTag::ExecuteAction as u8 => {
				Ok(MessageTag::ExecuteAction)
			}
			x if x == MessageTag::Config as u8 => Ok(MessageTag::Config),
			_ => Err(-9),
		}
	}
}
