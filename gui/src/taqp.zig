const std = @import("std");
const mach = @import("mach");
const Core = mach.Core;

pub const version: std.SemanticVersion = .{
    .major = 0,
    .minor = 0,
    .patch = 0,
};

const App = @import("App.zig");

// The set of Mach modules our application may use.
pub const Modules = mach.Modules(.{
    mach.Core,
    App,
});

// Global pointers
pub var core: *Core = undefined;
pub var app: *App = undefined;
