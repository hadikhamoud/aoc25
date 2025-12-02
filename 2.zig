const std = @import("std");
const utils = @import("utils.zig");

pub fn isValid(num: usize, allocator: std.mem.Allocator) !bool {
    const haystack_full = try std.fmt.allocPrint(allocator, "{d}{d}", .{ num, num });
    defer allocator.free(haystack_full);
    const haystack = haystack_full[1 .. haystack_full.len - 1];

    const needle = try std.fmt.allocPrint(allocator, "{d}", .{num});
    defer allocator.free(needle);

    const idx = std.mem.indexOf(u8, haystack, needle);
    if (idx == null)
        return true;
    return false;
}

pub fn isValidv1(num: usize, allocator: std.mem.Allocator) !bool {
    const haystack_full = try std.fmt.allocPrint(allocator, "{d}", .{num});
    defer allocator.free(haystack_full);

    if (@mod(haystack_full.len, 2) != 0) return true;
    const first_part = haystack_full[0..@divFloor(haystack_full.len, 2)];
    const second_part = haystack_full[@divFloor(haystack_full.len, 2)..haystack_full.len];
    if (std.mem.eql(u8, first_part, second_part)) {
        return false;
    }
    return true;
}

pub fn checkRepetitionInRange(range: []const u8, allocator: std.mem.Allocator, validator: fn (usize, std.mem.Allocator) anyerror!bool) !usize {
    var split_iterator = std.mem.splitAny(u8, range, "-");
    var total: usize = 0;

    const start = split_iterator.next() orelse return error.InvalidRange;
    const end = split_iterator.next() orelse return error.InvalidRange;

    const start_trimmed = std.mem.trim(u8, start, &std.ascii.whitespace);
    const end_trimmed = std.mem.trim(u8, end, &std.ascii.whitespace);

    const start_int = try std.fmt.parseInt(usize, start_trimmed, 10);
    const end_int = try std.fmt.parseInt(usize, end_trimmed, 10);
    for (start_int..end_int + 1) |i| {
        if (try validator(i, allocator) == false) {
            total = total + i;
        }
    }

    return total;
}

pub fn part1(use_test: bool) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var total: usize = 0;
    const input_path = if (use_test) "inputs_test/2.txt" else "inputs/2.txt";
    const file_str = try utils.loadFile(input_path, allocator);
    var split_iterator = std.mem.splitAny(u8, file_str, ",");
    while (split_iterator.next()) |part| {
        std.debug.print("range {s}\n", .{part});
        if (part.len > 0)
            total = total + try checkRepetitionInRange(part, allocator, isValid);
    }

    std.debug.print("Part 1 - total is {d}\n", .{total});
}

pub fn part2(use_test: bool) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var total: usize = 0;
    const input_path = if (use_test) "inputs_test/2.txt" else "inputs/2.txt";
    const file_str = try utils.loadFile(input_path, allocator);
    var split_iterator = std.mem.splitAny(u8, file_str, ",");
    while (split_iterator.next()) |part| {
        std.debug.print("range {s}\n", .{part});
        if (part.len > 0)
            total = total + try checkRepetitionInRange(part, allocator, isValidv1);
    }

    std.debug.print("Part 2 - total is {d}\n", .{total});
}

pub fn main() !void {
    const use_test = false;
    try part1(use_test);
    try part2(use_test);
}
