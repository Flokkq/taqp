const std = @import("std");

pub const os = @import("os/os.zig").os;

pub fn execute(action: Action) ActionError!void {
    try switch (action) {
        .IncreaseVolume => os.volume.increaseVolume(),
        .DecreaseVolume => os.volume.decreaseVolume(),
        .MuteVolume => os.volume.muteVolumne(),
    };
}

pub const Action = enum(u8) {
    MuteVolume = 0,
    IncreaseVolume = 1,
    DecreaseVolume = 2,

    pub fn from_int(val: u8) ?Action {
        return std.meta.intToEnum(@This(), val) catch null;
    }
};

pub const ActionError = error{VolumeChangeError};
