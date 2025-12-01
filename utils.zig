const std = @import("std");

pub fn loadFile(file_path: []const u8, allocator: std.mem.Allocator) ![]u8 {
    const file_stat = try std.fs.cwd().statFile(file_path);
    const file = try std.fs.cwd().readFileAlloc(allocator, file_path, file_stat.size);
    return file;
}
