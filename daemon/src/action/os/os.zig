const current_os = @import("../../os.zig").current_os;

pub const os =
    switch (current_os) {
    .Windows => @import("windows/windows.zig"),
    .Macos => @import("darwin/darwin.zig"),
    .Posix => @import("posix/posix.zig"),
};
