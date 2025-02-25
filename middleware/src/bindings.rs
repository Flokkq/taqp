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
	type Error = i32;

	fn try_from(value: u8) -> Result<Self, Self::Error> {
		match value {
			x if x == Self::MuteVolume as u8 => Ok(Self::MuteVolume),
			x if x == Self::IncreaseVolume as u8 => Ok(Self::IncreaseVolume),
			x if x == Self::DecreaseVolume as u8 => Ok(Self::DecreaseVolume),
			x if x == Self::Ignore as u8 => Ok(Self::Ignore),
			_ => Err(-2),
		}
	}
}
