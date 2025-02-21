const std = @import("std");

const mach = @import("mach");
const taqp = @import("../taqp.zig");

const App = taqp.App;
const Core = mach.Core;
const Sidebar = taqp.Sidebar;
const Pane = taqp.Sidebar.Pane;
const Editor = @This();

const imgui = @import("zig-imgui");

// Modules
pub const Schema = @import("schema/Schema.zig");

pub const mach_module = .editor;
pub const mach_systems = .{
    .init,
    .tick,
    .close,
    .deinit,
};

arena: std.heap.ArenaAllocator,
sidebar: *Sidebar,
pane: Pane = .overview,

// Module pointers
schema: *Schema,

pub fn init(
    app: *App,
    editor: *Editor,
    _schema: *Schema,
    _sidebar: *Sidebar,
    schema_mod: mach.Mod(Schema),
    sidebar_mod: mach.Mod(Sidebar),
) !void {
    _ = app;

    editor.* = .{
        .arena = std.heap.ArenaAllocator.init(std.heap.page_allocator),
        .schema = _schema,
        .sidebar = _sidebar,
    };

    schema_mod.call(.init);
    sidebar_mod.call(.init);
}

pub fn tick(
    core: *Core,
    app: *App,
    editor: *Editor,
    schema_mod: mach.Mod(Schema),
    sidebar_mod: mach.Mod(Sidebar),
) !void {
    imgui.pushStyleVarImVec2(imgui.StyleVar_SeparatorTextAlign, .{ .x = 0.1, .y = 0.5 });
    defer imgui.popStyleVar();

    // TODO: Draw tabs here
    sidebar_mod.call(.draw);
    schema_mod.call(.draw);

    _ = core;
    _ = app;

    _ = editor.arena.reset(.retain_capacity);
}

pub fn close(app: *App, editor: *Editor) void {
    _ = editor;

    app.should_close = true;
}

pub fn deinit(app: *App, editor: *Editor) !void {
    _ = app;
    editor.arena.deinit();
}
