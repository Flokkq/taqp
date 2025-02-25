const std = @import("std");
const taqp = @import("../../taqp.zig");

const imgui = @import("zig-imgui");
const Schema = taqp.Schema;
const App = taqp.App;

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

    const avail = imgui.getContentRegionAvail();

    // Start a child to contain the entire pad
    if (imgui.beginChild(
        "MacroPadBlueprint",
        .{ .x = avail.x, .y = avail.y },
        // If you want a visible border around it:
        imgui.ChildFlags_None,
        // Optional window flags
        imgui.WindowFlags_ChildWindow,
    )) {
        // Customize some style if you want
        imgui.pushStyleVarImVec2(imgui.StyleVar_ItemSpacing, .{ .x = 5.0, .y = 5.0 });
        defer imgui.popStyleVar();

        // Let’s define a 3-row × 4-col layout, with the “rotary” at row=0 col=3.
        const rows = 3;
        const cols = 4;

        // The size of each key cell
        const cell_w: f32 = 70.0;
        const cell_h: f32 = 70.0;
        // We’ll grab the top-left in screen space
        const origin = imgui.getCursorScreenPos();

        // Just loop
        for (0..rows) |row| {
            for (0..cols) |col| {
                // Compute where to place the button
                const x = origin.x + @as(f32, @floatFromInt(col)) * (cell_w + 10.0);
                const y = origin.y + @as(f32, @floatFromInt(row)) * (cell_h + 10.0);

                // Put the cursor there
                imgui.setCursorScreenPos(.{ .x = x, .y = y });

                // We'll create a unique ID for each cell so ImGui handles them distinctly
                imgui.pushIDInt(@as(c_int, @intCast(row * cols + col)));
                defer imgui.popID();

                // Check if this is the "rotary" cell:
                if (row == 0 and col == (cols - 1)) {
                    // We push a large rounding so it looks circular
                    imgui.pushStyleVar(imgui.StyleVar_FrameRounding, cell_w * 0.5);
                    defer imgui.popStyleVar();

                    // The label can show the current slide, if you like
                    const rotary_label = try std.fmt.allocPrintZ(
                        std.heap.page_allocator,
                        "{d}",
                        .{schema.current_slide},
                    );
                    defer std.heap.page_allocator.free(rotary_label);

                    // Use buttonEx or just button, either is fine
                    if (imgui.buttonEx(rotary_label, .{ .x = cell_w, .y = cell_h })) {
                        // Maybe cycle slides, e.g.
                        schema.current_slide = (schema.current_slide + 1) % 8;
                    }
                } else {
                    // Normal "square" key
                    // You can label them however you like:
                    const label = try std.fmt.allocPrintZ(
                        std.heap.page_allocator,
                        "{d},{d}",
                        .{ row, col },
                    );
                    defer std.heap.page_allocator.free(label);

                    if (imgui.buttonEx(label, .{ .x = cell_w, .y = cell_h })) {
                        // TODO: set that key's "action" or show a config popup, etc.
                    }
                }
            }
        }
    }
    imgui.endChild();
}
