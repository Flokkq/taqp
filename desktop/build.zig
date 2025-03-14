const std = @import("std");

const content_dir = "assets/";

const ProcessFontsStep = @import("src/tools/process_assets.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create our Mach app module, where all our code lives.
    const taqp_mod = b.createModule(.{
        .root_source_file = b.path("src/taqp.zig"),
        .optimize = optimize,
        .target = target,
    });

    // Add Mach import to our app.
    const mach_dep = b.dependency("mach", .{
        .target = target,
        .optimize = optimize,
    });

    const zig_imgui_dep = b.dependency("zig_imgui", .{ .target = target, .optimize = optimize });

    const imgui_module = b.addModule("zig-imgui", .{
        .root_source_file = zig_imgui_dep.path("src/imgui.zig"),
        .imports = &.{
            .{ .name = "mach", .module = mach_dep.module("mach") },
        },
    });

    taqp_mod.addImport("mach", mach_dep.module("mach"));
    taqp_mod.addImport("zig-imgui", imgui_module);

    // Have Mach create the executable for us
    const exe = @import("mach").addExecutable(mach_dep.builder, .{
        .name = "taqp-desktop",
        .app = taqp_mod,
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    exe.linkLibrary(zig_imgui_dep.artifact("imgui"));

    const fonts = try ProcessFontsStep.init(b, "assets", "src/generated/");
    var process_fonts_step = b.step("process-assets", "generates struct for all assets");
    process_fonts_step.dependOn(&fonts.step);
    exe.step.dependOn(process_fonts_step);

    const install_content_step = b.addInstallDirectory(.{
        .source_dir = .{ .cwd_relative = thisDir() ++ "/" ++ content_dir },
        .install_dir = .{ .custom = "" },
        .install_subdir = "bin/" ++ content_dir,
    });
    exe.step.dependOn(&install_content_step.step);

    // Run the app when `zig build run` is invoked
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Run tests when `zig build test` is run
    const app_unit_tests = b.addTest(.{
        .root_module = taqp_mod,
    });
    const run_app_unit_tests = b.addRunArtifact(app_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_app_unit_tests.step);
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
