const std = @import("std");
const utils = @import("utils.zig");

const Range = struct { start: usize, end: usize };
const Coords = struct { row: i8, col: i8 };

pub fn part1(use_test: bool) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input_path = if (use_test) "inputs_test/5.txt" else "inputs/5.txt";
    const file_str = try utils.loadFile(input_path, allocator);

    var lines = std.ArrayList([]const u8){};
    defer lines.deinit(allocator);

    var split_iterator = std.mem.splitSequence(u8, file_str, "\n\n");
    const ranges = split_iterator.next() orelse return error.InvalidRange;
    const values = split_iterator.next() orelse return error.InvalidRange;
    const values_trimmed = std.mem.trim(u8, values, &std.ascii.whitespace);
    var ranges_list = std.ArrayList(Range){};
    defer ranges_list.deinit(allocator);

    var split_ranges = std.mem.splitSequence(u8, ranges, "\n");
    while (split_ranges.next()) |range| {
        var split_range = std.mem.splitSequence(u8, range, "-");

        const range_start_str = split_range.next() orelse return error.InvalidRange;
        const range_end_str = split_range.next() orelse return error.InvalidRange;

        const range_start = try std.fmt.parseInt(usize, range_start_str, 10);
        const range_end = try std.fmt.parseInt(usize, range_end_str, 10);

        try ranges_list.append(allocator, Range{ .start = range_start, .end = range_end });
    }

    var total: i32 = 0;

    var split_values = std.mem.splitSequence(u8, values_trimmed, "\n");
    while (split_values.next()) |value_str| {
        const value = try std.fmt.parseInt(usize, value_str, 10);
        for (ranges_list.items) |range| {
            if (value >= range.start and value <= range.end) {
                total += 1;
                break;
            }
        }
    }

    std.debug.print("part 1: fresh fruits found {d}\n", .{total});
}

pub fn part2(use_test: bool) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input_path = if (use_test) "inputs_test/5.txt" else "inputs/5.txt";
    const file_str = try utils.loadFile(input_path, allocator);

    var lines = std.ArrayList([]const u8){};
    defer lines.deinit(allocator);

    var split_iterator = std.mem.splitSequence(u8, file_str, "\n\n");
    const ranges_str = split_iterator.next() orelse return error.InvalidRange;
    var ranges = std.ArrayList(Range){};
    defer ranges.deinit(allocator);

    var split_ranges = std.mem.splitSequence(u8, ranges_str, "\n");
    while (split_ranges.next()) |range| {
        var split_range = std.mem.splitSequence(u8, range, "-");

        const range_start_str = split_range.next() orelse return error.InvalidRange;
        const range_end_str = split_range.next() orelse return error.InvalidRange;

        const range_start = try std.fmt.parseInt(usize, range_start_str, 10);
        const range_end = try std.fmt.parseInt(usize, range_end_str, 10);

        try ranges.append(allocator, Range{ .start = range_start, .end = range_end });
    }

    var total: usize = 0;

    std.mem.sort(Range, ranges.items, {}, struct {
        fn lessThan(_: void, a: Range, b: Range) bool {
            return a.start < b.start;
        }
    }.lessThan);

    var merged = std.ArrayList(Range){};
    defer merged.deinit(allocator);
    var current = ranges.items[0];
    for (ranges.items[1..]) |next_range| {
        if (next_range.start <= current.end + 1) {
            current.end = @max(current.end, next_range.end);
        } else {
            try merged.append(allocator, current);
            current = next_range;
        }
    }

    try merged.append(allocator, current);
    for (merged.items) |range| {
        total += range.end - range.start + 1;
    }

    std.debug.print("part 2: fresh fruits found {d}", .{total});
}

pub fn main() !void {
    const use_test = false;
    try part1(use_test);
    try part2(use_test);
}
