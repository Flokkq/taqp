const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "core",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    switch (builtin.os.tag) {
        .macos => linkDarwinDependencies(exe),
        .linux, .openbsd, .freebsd => {},
        .windows => {},
        else => @compileError("Unsupported OS"),
    }

    const rust_lib = try setupMiddleware(b, optimize);
    exe.addLibraryPath(rust_lib.dirname());
    exe.linkSystemLibrary("bridge");

    const bindings_path = b.path("../bridge/src/bindings.zig");
    const bindings_module = b.addModule("bindings", .{ .root_source_file = bindings_path });
    exe.addIncludePath(b.path("../bridge/src"));
    exe.root_module.addImport("bindings", bindings_module);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}

fn linkDarwinDependencies(exe: *std.Build.Step.Compile) void {
    exe.linkFramework("CoreAudio");
    exe.linkFramework("AudioToolbox");
}

fn setupMiddleware(b: *std.Build, opt: std.builtin.OptimizeMode) !std.Build.LazyPath {
    const base_path = b.path("../bridge");
    const lib_name = "libbridge";

    const tool_run = b.addSystemCommand(&.{"cargo"});
    tool_run.setCwd(base_path);
    tool_run.addArg("build");

    var opt_path: []const u8 = undefined;
    switch (opt) {
        .ReleaseSafe, .ReleaseFast, .ReleaseSmall => {
            tool_run.addArg("--release");
            opt_path = "release";
        },
        .Debug => opt_path = "debug",
    }

    var lib_ext: []const u8 = "";
    switch (builtin.os.tag) {
        .windows => lib_ext = ".dll",
        .macos => lib_ext = ".dylib",
        .linux, .openbsd, .freebsd => lib_ext = ".so",
        else => @compileError("Unsupported OS"),
    }
    const lib_filename = try std.mem.concat(b.allocator, u8, &.{ lib_name, lib_ext });

    const generated = try b.allocator.create(std.Build.GeneratedFile);
    generated.* = .{
        .step = &tool_run.step,
        .path = try std.fs.path.join(
            b.allocator,
            &.{ base_path.getPath(b), "target", opt_path, lib_filename },
        ),
    };

    return std.Build.LazyPath{ .generated = .{ .file = generated } };
}
