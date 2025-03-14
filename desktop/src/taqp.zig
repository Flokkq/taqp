const std = @import("std");
const mach = @import("mach");
const Core = mach.Core;

pub const version: std.SemanticVersion = .{
    .major = 0,
    .minor = 0,
    .patch = 0,
};

// Generated files, these contain helpers for autocomplete
pub const paths = @import("generated/fonts.zig");

pub const App = @import("App.zig");
pub const Editor = @import("editor/Editor.zig");
pub const Schema = @import("editor/schema/Schema.zig");
pub const Sidebar = @import("editor/Sidebar.zig");

// The set of Mach modules our application may use.
pub const Modules = mach.Modules(.{
    mach.Core,
    App,
    Editor,
    Sidebar,
    Schema,
});

// Global pointers
pub var core: *Core = undefined;
pub var app: *App = undefined;
pub var editor: *Editor = undefined;
