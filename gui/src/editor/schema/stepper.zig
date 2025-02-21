const std = @import("std");
const taqp = @import("../../taqp.zig");

const Schema = taqp.Schema;
const App = taqp.App;
const imgui = @import("zig-imgui");

pub fn draw(schema: *Schema) !void {
    imgui.pushStyleVarImVec2(imgui.StyleVar_WindowPadding, .{ .x = 10.0, .y = 10.0 });
    imgui.pushStyleVarImVec2(imgui.StyleVar_ItemSpacing, .{ .x = 20.0, .y = 10.0 });
    defer imgui.popStyleVarEx(2);

    imgui.pushStyleColorImVec4(imgui.Col_Text, .{
        .x = @as(f32, @floatFromInt(97)) / 255,
        .y = @as(f32, @floatFromInt(97)) / 255,
        .z = @as(f32, @floatFromInt(107)) / 255,
        .w = @as(f32, @floatFromInt(255)) / 255,
    });
    imgui.pushStyleColorImVec4(imgui.Col_ButtonHovered, .{
        .x = @as(f32, @floatFromInt(42)) / 255,
        .y = @as(f32, @floatFromInt(44)) / 255,
        .z = @as(f32, @floatFromInt(54)) / 255,
        .w = @as(f32, @floatFromInt(255)) / 255,
    });
    imgui.pushStyleColorImVec4(imgui.Col_Button, .{
        .x = @as(f32, @floatFromInt(34)) / 255,
        .y = @as(f32, @floatFromInt(35)) / 255,
        .z = @as(f32, @floatFromInt(42)) / 255,
        .w = @as(f32, @floatFromInt(255)) / 255,
    });
    imgui.pushStyleColorImVec4(imgui.Col_ButtonActive, .{
        .x = @as(f32, @floatFromInt(34)) / 255,
        .y = @as(f32, @floatFromInt(35)) / 255,
        .z = @as(f32, @floatFromInt(42)) / 255,
        .w = @as(f32, @floatFromInt(255)) / 255,
    });
    imgui.pushStyleColorImVec4(imgui.Col_Border, .{
        .x = @as(f32, @floatFromInt(34)) / 255,
        .y = @as(f32, @floatFromInt(35)) / 255,
        .z = @as(f32, @floatFromInt(42)) / 255,
        .w = @as(f32, @floatFromInt(255)) / 255,
    });
    defer imgui.popStyleColorEx(5);

    // TODO: Load a bigger font just for this i guess
    imgui.setWindowFontScale(3.0);
    defer imgui.setWindowFontScale(1.0);

    for (0..8) |idx| {
        var buf: [4]u8 = undefined;
        const text = std.fmt.bufPrintZ(&buf, "{d}", .{idx}) catch unreachable;
        const size = imgui.calcTextSize(text);
        const w = size.x * 3;
        const h = 0.0;

        if (imgui.buttonEx(text, .{ .x = w, .y = h })) {
            schema.current_slide = @intCast(idx);
        }

        if (idx < 8 - 1) {
            imgui.sameLine();
        }
    }
}
