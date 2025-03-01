const std = @import("std");

const os = @import("os/os.zig").os;
const discord = @import("discord.zig");

pub fn execute(action: Action) ActionError!void {
    try switch (action) {
        .IncreaseVolume => os.volume.increaseVolume(),
        .DecreaseVolume => os.volume.decreaseVolume(),
        .MuteVolume => os.volume.muteVolumne(),
        .Discord => discord.connectToClient(),
    };
}

pub const Action = enum(u8) {
    MuteVolume,
    IncreaseVolume,
    DecreaseVolume,
    Discord,

    pub fn from_int(val: u8) ?Action {
        return std.meta.intToEnum(@This(), val) catch null;
    }
};

pub const ActionError = error{
    VolumeChangeError,
    DiscordConnectionErrror,
    NoAvailableSocket,
    ResourceLimitReached,
};
