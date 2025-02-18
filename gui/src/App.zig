const std = @import("std");
const builtin = @import("builtin");

const mach = @import("mach");
const gpu = mach.gpu;

const imgui = @import("zig-imgui");
const imgui_mach = imgui.backends.mach;

const App = @This();
const Core = mach.Core;

pub const Modules = mach.Modules(.{
    mach.Core,
    App,
});

// The set of Mach modules our application may use.
pub const mach_module = .app;
pub const mach_systems = .{ .main, .init, .lateInit, .tick, .deinit };

pub const main = mach.schedule(.{
    .{ Core, .init },
    .{ App, .init },
    .{ Core, .main },
});

allocator: std.mem.Allocator = undefined,
window: mach.ObjectID,
timer: mach.time.Timer,
pipeline_compute: *gpu.ComputePipeline = undefined,
pipeline_default: *gpu.RenderPipeline = undefined,

var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;

pub fn init(
    core: *Core,
    app: *App,
    app_mod: mach.Mod(App),
) !void {
    core.on_tick = app_mod.id.tick;
    core.on_exit = app_mod.id.deinit;

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
    const window = core.windows.getValue(app.window);

    imgui.setZigAllocator(&app.allocator);
    _ = imgui.createContext(null);
    try imgui_mach.init(core, app.allocator, window.device, .{
        .mag_filter = .nearest,
        .min_filter = .nearest,
        .mipmap_filter = .nearest,
        .color_format = window.framebuffer_format,
    });
}

pub fn tick(app: *App, core: *mach.Core, app_mod: mach.Mod(App)) !void {
    const label = @tagName(mach_module) ++ ".tick";

    while (core.nextEvent()) |event| {
        switch (event) {
            .window_open => {
                app_mod.call(.lateInit);
            },
            .close => core.exit(),
            else => {},
        }
    }

    const window = core.windows.getValue(app.window);

    // New imgui frame
    try imgui_mach.newFrame();
    imgui.newFrame();

    // Render imgui
    imgui.render();

    if (window.swap_chain.getCurrentTextureView()) |back_buffer_view| {
        defer back_buffer_view.release();

        const imgui_commands = commands: {
            const encoder = window.device.createCommandEncoder(&.{ .label = label });
            defer encoder.release();

            const background: gpu.Color = .{
                .r = 1.0,
                .g = 0.5,
                .b = 0.5,
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
    }
}

pub fn deinit(app: *App) void {
    app.pipeline_default.release();
    app.pipeline_compute.release();

    imgui_mach.shutdown();
    imgui.getIO().fonts.?.clear();
    imgui.destroyContext(null);

    _ = gpa.detectLeaks();
    _ = gpa.deinit();
}
