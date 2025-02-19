const taqp = @import("../taqp.zig");
const Core = @import("mach").Core;

const App = taqp.App;
const Editor = taqp.Editor;

const imgui = @import("zig-imgui");

pub const Sidebar = @This();

pub const mach_module = .sidebar;
pub const mach_systems = .{ .init, .deinit, .draw };

pub fn init(sidebar: *Sidebar) void {
    sidebar.* = .{};
}

pub fn deinit() void {
    // TODO
}

pub fn draw(app: *App, editor: *Editor) !void {
    imgui.pushStyleVar(imgui.StyleVar_WindowRounding, 0.0);
    defer imgui.popStyleVar();

    imgui.setNextWindowPos(.{
        .x = 0.0,
        .y = 0.0,
    }, imgui.Cond_Always);
    imgui.setNextWindowSize(.{
        .x = 50,
        .y = app.window_size[1],
    }, imgui.Cond_None);

    imgui.pushStyleVarImVec2(imgui.StyleVar_SelectableTextAlign, .{ .x = 0.5, .y = 0.5 });
    imgui.pushStyleColorImVec4(imgui.Col_Header, .{
        .x = @as(f32, @floatFromInt(42)) / 255,
        .y = @as(f32, @floatFromInt(44)) / 255,
        .z = @as(f32, @floatFromInt(54)) / 255,
        .w = @as(f32, @floatFromInt(255)) / 255,
    });
    imgui.pushStyleColorImVec4(imgui.Col_WindowBg, .{
        .x = @as(f32, @floatFromInt(42)) / 255,
        .y = @as(f32, @floatFromInt(44)) / 255,
        .z = @as(f32, @floatFromInt(54)) / 255,
        .w = @as(f32, @floatFromInt(255)) / 255,
    });
    defer imgui.popStyleVar();
    defer imgui.popStyleColorEx(2);

    var sidebar_flags: imgui.WindowFlags = 0;
    sidebar_flags |= imgui.WindowFlags_NoTitleBar;
    sidebar_flags |= imgui.WindowFlags_NoResize;
    sidebar_flags |= imgui.WindowFlags_NoMove;
    sidebar_flags |= imgui.WindowFlags_NoCollapse;
    sidebar_flags |= imgui.WindowFlags_NoScrollbar;
    sidebar_flags |= imgui.WindowFlags_NoScrollWithMouse;
    sidebar_flags |= imgui.WindowFlags_NoBringToFrontOnFocus;

    if (imgui.begin("Sidebar", null, sidebar_flags)) {
        imgui.pushStyleColorImVec4(imgui.Col_HeaderHovered, .{
            .x = @as(f32, @floatFromInt(42)) / 255,
            .y = @as(f32, @floatFromInt(44)) / 255,
            .z = @as(f32, @floatFromInt(54)) / 255,
            .w = @as(f32, @floatFromInt(255)) / 255,
        });
        imgui.pushStyleColorImVec4(imgui.Col_HeaderActive, .{
            .x = @as(f32, @floatFromInt(42)) / 255,
            .y = @as(f32, @floatFromInt(44)) / 255,
            .z = @as(f32, @floatFromInt(54)) / 255,
            .w = @as(f32, @floatFromInt(255)) / 255,
        });
        defer imgui.popStyleColorEx(2);

        drawOption("\u{f07c}");
    }
    _ = editor;

    imgui.end();
}

fn drawOption(icon: [:0]const u8) void {
    const position = imgui.getCursorPos();
    const selectable_width = (50 - 8);
    const selectable_height = (50 - 8);

    imgui.dummy(.{
        .x = selectable_width,
        .y = selectable_height,
    });

    imgui.setCursorPos(position);

    if (imgui.isItemHovered(imgui.HoveredFlags_None)) {
        imgui.pushStyleColorImVec4(imgui.Col_Text, .{
            .x = @as(f32, @floatFromInt(230)) / 255,
            .y = @as(f32, @floatFromInt(175)) / 255,
            .z = @as(f32, @floatFromInt(137)) / 255,
            .w = @as(f32, @floatFromInt(255)) / 255,
        });
    } else {
        imgui.pushStyleColorImVec4(imgui.Col_Text, .{
            .x = @as(f32, @floatFromInt(159)) / 255,
            .y = @as(f32, @floatFromInt(159)) / 255,
            .z = @as(f32, @floatFromInt(176)) / 255,
            .w = @as(f32, @floatFromInt(255)) / 255,
        });
    }

    const selectable_flags: imgui.SelectableFlags = imgui.SelectableFlags_DontClosePopups;
    _ = imgui.selectableEx(icon, true, selectable_flags, .{ .x = selectable_width, .y = selectable_height });

    imgui.popStyleColor();
}
