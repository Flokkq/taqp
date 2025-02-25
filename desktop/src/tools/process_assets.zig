const std = @import("std");
const path = std.fs.path;
const Step = std.Build.Step;

pub const ProcessFontsStep = @This();
step: Step,
builder: *std.Build,
fonts_path: []const u8,
output_folder: []const u8,

pub fn init(builder: *std.Build, comptime fonts_path: []const u8, comptime output_folder: []const u8) !*ProcessFontsStep {
    const self = try builder.allocator.create(ProcessFontsStep);
    self.* = .{
        .step = Step.init(.{
            .id = .custom,
            .name = "process-fonts",
            .owner = builder,
            .makeFn = process,
        }),
        .builder = builder,
        .fonts_path = fonts_path,
        .output_folder = output_folder,
    };
    return self;
}

fn process(step: *Step, options: Step.MakeOptions) anyerror!void {
    const progress = options.progress_node.start("Processing fonts...", 100);
    defer progress.end();
    const self = @as(*ProcessFontsStep, @fieldParentPtr("step", step));
    try self.generate(self.builder.allocator, self.fonts_path, self.output_folder);
}

pub fn generate(self: *ProcessFontsStep, allocator: std.mem.Allocator, fonts_root: []const u8, output_folder: []const u8) !void {
    _ = self;
    const files = try getAllFiles(allocator, fonts_root, true);
    var fonts_list = std.ArrayList(u8).init(allocator);
    var writer = fonts_list.writer();

    try writer.writeAll("// Generated fonts file. Do not edit.\n\n");
    try writer.print("// Fonts\n\n", .{});

    for (files) |file| {
        const ext = std.fs.path.extension(file);
        if (!(std.mem.eql(u8, ext, ".ttf") or std.mem.eql(u8, ext, ".otf"))) continue;

        const base = std.fs.path.basename(file);
        const ext_ind = std.mem.lastIndexOf(u8, base, ".");
        const name = base[0..ext_ind.?];

        const path_fixed = try allocator.alloc(u8, file.len);
        _ = std.mem.replace(u8, file, "\\", "/", path_fixed);

        const name_fixed = try allocator.alloc(u8, name.len);
        _ = std.mem.replace(u8, name, "-", "_", name_fixed);

        try writer.print("pub const @\"{s}\" = \"{s}\";\n", .{ base, path_fixed });
    }

    try std.fs.cwd().writeFile(.{
        .sub_path = try path.join(allocator, &[_][]const u8{ output_folder, "fonts.zig" }),
        .data = fonts_list.items,
    });
}

fn getAllFiles(allocator: std.mem.Allocator, root_directory: []const u8, recurse: bool) ![][:0]const u8 {
    var list = std.ArrayList([:0]const u8).init(allocator);

    const recursor = struct {
        fn search(alloc: std.mem.Allocator, directory: []const u8, recursive: bool, filelist: *std.ArrayList([:0]const u8)) !void {
            var dir = try std.fs.cwd().openDir(directory, .{ .access_sub_paths = true, .iterate = true });
            defer dir.close();
            var iter = dir.iterate();
            while (try iter.next()) |entry| {
                if (entry.kind == .file) {
                    const name_null = try std.mem.concat(alloc, u8, &[_][]const u8{ entry.name, "\x00" });
                    const abs_path = try path.join(alloc, &[_][]const u8{ directory, name_null });
                    try filelist.append(abs_path[0 .. abs_path.len - 1 :0]);
                } else if (entry.kind == .directory) {
                    const abs_path = try path.join(alloc, &[_][]const u8{ directory, entry.name });
                    try search(alloc, abs_path, recursive, filelist);
                }
            }
        }
    }.search;

    try recursor(allocator, root_directory, recurse, &list);
    std.mem.sort([:0]const u8, list.items, Context{}, compare);
    return try list.toOwnedSlice();
}

const Context = struct {};
fn compare(_: Context, a: [:0]const u8, b: [:0]const u8) bool {
    const base_a = path.basename(a);
    const base_b = path.basename(b);
    return std.mem.order(u8, base_a, base_b) == .lt;
}
