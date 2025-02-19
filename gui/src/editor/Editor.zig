const std = @import("std");

const mach = @import("mach");
const taqp = @import("../taqp.zig");

const App = taqp.App;
const Core = mach.Core;
const Editor = @This();

const imgui = @import("zig-imgui");

pub const mach_module = .editor;
pub const mach_systems = .{ .init, .tick, .close, .deinit };

arena: std.heap.ArenaAllocator,

pub fn init(app: *App, editor: *Editor) !void {
    _ = app;

    editor.* = .{ .arena = std.heap.ArenaAllocator.init(std.heap.page_allocator) };
}

pub fn tick(core: *Core, app: *App, editor: *Editor) !void {
    imgui.pushStyleVarImVec2(imgui.StyleVar_SeparatorTextAlign, .{ .x = 0.1, .y = 0.5 });
    defer imgui.popStyleVar();

    // TODO: Draw tabs here
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
