const std = @import("std");
const math = @import("math");

const darwin = @cImport({
    @cInclude("CoreAudio/CoreAudio.h");
    @cInclude("AudioToolbox/AudioToolbox.h");
});

const ActionError = @import("../../action.zig").ActionError;

pub fn increaseVolume() ActionError!void {
    changeVolume(0.1) catch |err| return err;
}

pub fn decreaseVolume() ActionError!void {
    changeVolume(-0.1) catch |err| return err;
}

pub fn muteVolumne() ActionError!void {
    changeVolume(-1.0) catch |err| return err;
}

fn changeVolume(d: f32) !void {
    var device_id: darwin.AudioObjectID = 0;
    var prosperity_address = darwin.AudioObjectPropertyAddress{
        .mSelector = darwin.kAudioHardwarePropertyDefaultOutputDevice,
        .mScope = darwin.kAudioObjectPropertyScopeGlobal,
        .mElement = darwin.kAudioObjectPropertyElementMaster,
    };

    var prosperity_size: darwin.UInt32 = @sizeOf(darwin.AudioObjectID);
    var status = darwin.AudioObjectGetPropertyData(
        darwin.kAudioObjectSystemObject,
        &prosperity_address,
        0,
        null,
        &prosperity_size,
        &device_id,
    );

    // TODO: provide error status mapping errors
    if (status != 0 or device_id == 0) return ActionError.VolumeChangeError;

    prosperity_address.mSelector = darwin.kAudioHardwareServiceDeviceProperty_VirtualMasterVolume;
    prosperity_address.mScope = darwin.kAudioDevicePropertyScopeOutput;

    var volume: f32 = 0.0;
    prosperity_size = @sizeOf(f32);

    status = darwin.AudioObjectGetPropertyData(
        device_id,
        &prosperity_address,
        0,
        null,
        &prosperity_size,
        &volume,
    );

    if (status != 0) return ActionError.VolumeChangeError;

    volume = std.math.clamp(volume + d, 0.0, 1.0);

    status = darwin.AudioObjectSetPropertyData(device_id, &prosperity_address, 0, null, prosperity_size, &volume);

    if (status != 0) return ActionError.VolumeChangeError;
}
