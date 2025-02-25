const std = @import("std");

const taqp = @import("../../taqp.zig");

const imgui = @import("zig-imgui");

const Core = @import("mach").Core;
const App = taqp.App;
const Editor = taqp.Editor;

const Schema = @This();
current_slide: u8 = 0,

pub const mach_module = .schema;
pub const mach_systems = .{ .init, .deinit, .draw };

pub const blueprint = @import("blueprint.zig");
pub const stepper = @import("stepper.zig");

pub fn init(schema: *Schema) void {
    schema.* = .{};
}

pub fn deinit() void {}

pub fn draw(schema: *Schema, core: *Core, app: *App, editor: *Editor) !void {
    _ = core;
    _ = editor;

    imgui.pushStyleVar(imgui.StyleVar_WindowRounding, 0.0);
    defer imgui.popStyleVar();
    imgui.setNextWindowPos(.{
        .x = 50,
        .y = 0.0,
    }, imgui.Cond_Always);
    imgui.setNextWindowSize(.{
        .x = app.window_size[0] - 50,
        .y = app.window_size[1] + 5.0,
    }, imgui.Cond_None);

    imgui.pushStyleVarImVec2(imgui.StyleVar_WindowPadding, .{ .x = 0.0, .y = 0.0 });
    imgui.pushStyleVar(imgui.StyleVar_TabRounding, 0.0);
    imgui.pushStyleVar(imgui.StyleVar_ChildBorderSize, 1.0);
    defer imgui.popStyleVarEx(3);

    var art_flags: imgui.WindowFlags = 0;
    art_flags |= imgui.WindowFlags_NoTitleBar;
    art_flags |= imgui.WindowFlags_NoResize;
    art_flags |= imgui.WindowFlags_NoMove;
    art_flags |= imgui.WindowFlags_NoCollapse;
    art_flags |= imgui.WindowFlags_MenuBar;
    art_flags |= imgui.WindowFlags_NoBringToFrontOnFocus;

    if (imgui.begin("Art", null, art_flags)) {
        try stepper.draw(schema);
        try blueprint.draw(schema);
    }
    imgui.end();
}
