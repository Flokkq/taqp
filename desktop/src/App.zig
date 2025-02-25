const std = @import("std");
const builtin = @import("builtin");

const mach = @import("mach");
const gpu = mach.gpu;

const imgui = @import("zig-imgui");
const imgui_mach = imgui.backends.mach;

const taqp = @import("taqp.zig");

const App = @This();
const Editor = taqp.Editor;
const Core = mach.Core;

// The set of Mach modules our application may use.
pub const mach_module = .app;
pub const mach_systems = .{ .main, .init, .lateInit, .tick, .deinit };

pub const main = mach.schedule(.{
    .{ Core, .init },
    .{ App, .init },
    .{ Editor, .init },
    .{ Core, .main },
});

allocator: std.mem.Allocator = undefined,
window: mach.ObjectID,
timer: mach.time.Timer,
window_size: [2]f32 = undefined,
framebuffer_size: [2]f32 = undefined,
content_scale: [2]f32 = undefined,
should_close: bool = false,

var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;

pub fn init(
    core: *Core,
    app: *App,
    editor: *Editor,
    app_mod: mach.Mod(App),
) !void {
    taqp.app = app;
    taqp.core = core;
    taqp.editor = editor;

    taqp.core.on_tick = app_mod.id.tick;
    taqp.core.on_exit = app_mod.id.deinit;

    const allocator = if (builtin.mode == .Debug) gpa.allocator() else std.heap.c_allocator;

    const window = try core.windows.new(.{
        .title = "taqp",
    });

    // Store our render pipeline in our module's state, so we can access it later on.
    app.* = .{
        .allocator = allocator,
        .window = window,
        .timer = try mach.time.Timer.start(),
    };
}

/// This is called from the event fired when the window is done being
/// initialized by the platform
pub fn lateInit(app: *App, core: *Core) !void {
    const window = taqp.core.windows.getValue(app.window);

    app.window_size = .{ @floatFromInt(window.width), @floatFromInt(window.height) };
    app.framebuffer_size = .{ @floatFromInt(window.framebuffer_width), @floatFromInt(window.framebuffer_height) };
    app.content_scale = .{
        app.framebuffer_size[0] / app.window_size[0],
        app.framebuffer_size[1] / app.window_size[1],
    };

    imgui.setZigAllocator(&app.allocator);
    _ = imgui.createContext(null);
    try imgui_mach.init(core, app.allocator, window.device, .{
        .mag_filter = .nearest,
        .min_filter = .nearest,
        .mipmap_filter = .nearest,
        .color_format = window.framebuffer_format,
    });

    // Load fonts
    var io = imgui.getIO();
    io.config_flags |= imgui.ConfigFlags_NavEnableKeyboard;
    io.display_framebuffer_scale = .{ .x = app.content_scale[0], .y = app.content_scale[1] };
    io.font_global_scale = 1.0;

    var cozette_config: imgui.FontConfig = std.mem.zeroes(imgui.FontConfig);
    cozette_config.font_data_owned_by_atlas = true;
    cozette_config.oversample_h = 2;
    cozette_config.oversample_v = 1;
    cozette_config.glyph_max_advance_x = std.math.floatMax(f32);
    cozette_config.rasterizer_multiply = 1.0;
    cozette_config.rasterizer_density = 1.0;
    cozette_config.ellipsis_char = imgui.UNICODE_CODEPOINT_MAX;

    _ = io.fonts.?.addFontFromFileTTF(taqp.paths.@"CozetteVector.ttf", 13.0, &cozette_config, null);

    var fa_config: imgui.FontConfig = std.mem.zeroes(imgui.FontConfig);
    fa_config.merge_mode = true;
    fa_config.font_data_owned_by_atlas = true;
    fa_config.oversample_h = 2;
    fa_config.oversample_v = 1;
    fa_config.glyph_max_advance_x = std.math.floatMax(f32);
    fa_config.rasterizer_multiply = 1.0;
    fa_config.rasterizer_density = 1.0;
    fa_config.ellipsis_char = imgui.UNICODE_CODEPOINT_MAX;
    const ranges: []const u16 = &.{ 0xf000, 0xf976, 0 };

    _ = io.fonts.?.addFontFromFileTTF(taqp.paths.@"fa-solid-900.ttf", 13.0, &fa_config, @ptrCast(ranges.ptr)).?;
    _ = io.fonts.?.addFontFromFileTTF(taqp.paths.@"fa-regular-400.ttf", 13.0, &fa_config, @ptrCast(ranges.ptr)).?;
}

pub fn tick(app: *App, core: *mach.Core, app_mod: mach.Mod(App), editor_mod: mach.Mod(Editor)) !void {
    const label = @tagName(mach_module) ++ ".tick";

    while (core.nextEvent()) |event| {
        switch (event) {
            .window_open => {
                app_mod.call(.lateInit);
            },
            .window_resize => |resize| {
                const window = core.windows.getValue(app.window);
                app.window_size = .{ @floatFromInt(resize.size.width), @floatFromInt(resize.size.height) };
                app.framebuffer_size = .{ @floatFromInt(window.framebuffer_width), @floatFromInt(window.framebuffer_height) };
                app.content_scale = .{
                    app.framebuffer_size[0] / app.window_size[0],
                    app.framebuffer_size[1] / app.window_size[1],
                };
            },
            .close => {
                editor_mod.call(.close);
            },
            else => {},
        }

        if (!app.should_close) {
            if (imgui.getCurrentContext() != null) {
                _ = imgui_mach.processEvent(event);
            }
        }
    }

    var window = core.windows.getValue(app.window);

    // New imgui frame
    try imgui_mach.newFrame();
    imgui.newFrame();

    editor_mod.call(.tick);

    // Render imgui
    imgui.render();

    if (window.swap_chain.getCurrentTextureView()) |back_buffer_view| {
        defer back_buffer_view.release();

        const imgui_commands = commands: {
            const encoder = window.device.createCommandEncoder(&.{ .label = label });
            defer encoder.release();

            const background: gpu.Color = .{
                .r = @as(f32, @floatFromInt(34)) / 255.0,
                .g = @as(f32, @floatFromInt(35)) / 255.0,
                .b = @as(f32, @floatFromInt(42)) / 255.0,
                .a = 1.0,
            };

            // Gui pass.
            {
                const color_attachment = gpu.RenderPassColorAttachment{
                    .view = back_buffer_view,
                    .clear_value = background,
                    .load_op = .clear,
                    .store_op = .store,
                };

                const render_pass_info = gpu.RenderPassDescriptor.init(.{
                    .color_attachments = &.{color_attachment},
                });
                const pass = encoder.beginRenderPass(&render_pass_info);

                imgui_mach.renderDrawData(imgui.getDrawData().?, pass) catch {};
                pass.end();
                pass.release();
            }

            break :commands encoder.finish(&.{ .label = label });
        };
        defer imgui_commands.release();

        window.queue.submit(&.{imgui_commands});

        if (app.should_close) {
            core.exit();
        }
    }
}

pub fn deinit(app: *App, editor_mod: mach.Mod(Editor)) void {
    editor_mod.call(.deinit);

    imgui_mach.shutdown();
    imgui.getIO().fonts.?.clear();
    imgui.destroyContext(null);

    _ = gpa.detectLeaks();
    _ = gpa.deinit();

    _ = app;
}
