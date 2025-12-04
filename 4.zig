const std = @import("std");
const utils = @import("utils.zig");

const Coords = struct { row: i8, col: i8 };

pub fn part1(use_test: bool) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input_path = if (use_test) "inputs_test/4.txt" else "inputs/4.txt";
    const file_str = try utils.loadFile(input_path, allocator);

    var lines = std.ArrayList([]const u8){};
    defer lines.deinit(allocator);

    var split_iterator = std.mem.splitAny(u8, file_str, "\n");
    while (split_iterator.next()) |line| {
        if (line.len == 0) continue;
        try lines.append(allocator, line);
    }

    const directions = [_]Coords{
        .{ .row = 1, .col = 0 }, // down
        .{ .row = 0, .col = 1 }, // right
        .{ .row = -1, .col = 0 }, // up
        .{ .row = 0, .col = -1 }, // left
        .{ .row = 1, .col = 1 }, // down-right
        .{ .row = -1, .col = 1 }, // up-right
        .{ .row = 1, .col = -1 }, // down-left
        .{ .row = -1, .col = -1 }, // up-left
    };

    var matrix = try allocator.alloc([]const u8, lines.items.len);
    defer allocator.free(matrix);

    for (lines.items, 0..) |line, i| {
        matrix[i] = line;
    }

    var total: i32 = 0;
    const max_x: i32 = @intCast(matrix.len);
    const max_y: i32 = @intCast(matrix[0].len);

    for (matrix, 0..) |row, row_idx| {
        for (row, 0..) |_, col_idx| {
            var subtotal: i32 = 0;
            if (matrix[row_idx][col_idx] != '@') continue;
            for (directions) |coords| {
                const nr: i32 = @as(i32, @intCast(row_idx)) + coords.row;
                const nc: i32 = @as(i32, @intCast(col_idx)) + coords.col;
                if (nr >= 0 and nr < max_x and nc >= 0 and nc < max_y) {
                    const nr_usize: usize = @intCast(nr);
                    const nc_usize: usize = @intCast(nc);
                    if (matrix[nr_usize][nc_usize] == '@') subtotal += 1;
                }
            }
            if (subtotal < 4) total += 1;
        }
    }
    std.debug.print("Total valid positions: {d}\n", .{total});
}

pub fn part2(use_test: bool) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input_path = if (use_test) "inputs_test/4.txt" else "inputs/4.txt";
    const file_str = try utils.loadFile(input_path, allocator);

    var lines = std.ArrayList([]const u8){};
    defer lines.deinit(allocator);

    var split_iterator = std.mem.splitAny(u8, file_str, "\n");
    while (split_iterator.next()) |line| {
        if (line.len == 0) continue;
        try lines.append(allocator, line);
    }

    const directions = [_]Coords{
        .{ .row = 1, .col = 0 }, // down
        .{ .row = 0, .col = 1 }, // right
        .{ .row = -1, .col = 0 }, // up
        .{ .row = 0, .col = -1 }, // left
        .{ .row = 1, .col = 1 }, // down-right
        .{ .row = -1, .col = 1 }, // up-right
        .{ .row = 1, .col = -1 }, // down-left
        .{ .row = -1, .col = -1 }, // up-left
    };

    var matrix = try allocator.alloc([]u8, lines.items.len);
    defer {
        for (matrix) |row| {
            allocator.free(row);
        }
        allocator.free(matrix);
    }

    for (lines.items, 0..) |line, i| {
        matrix[i] = try allocator.dupe(u8, line);
    }

    var total: i32 = 0;
    const max_x: i32 = @intCast(matrix.len);
    const max_y: i32 = @intCast(matrix[0].len);

    const Position = struct { row: usize, col: usize };
    var to_remove = std.ArrayList(Position){};
    defer to_remove.deinit(allocator);

    var changed = true;
    while (changed) {
        changed = false;
        to_remove.clearRetainingCapacity();

        for (matrix, 0..) |row, row_idx| {
            for (row, 0..) |cell, col_idx| {
                if (cell != '@') continue;

                var subtotal: i32 = 0;
                for (directions) |coords| {
                    const nr: i32 = @as(i32, @intCast(row_idx)) + coords.row;
                    const nc: i32 = @as(i32, @intCast(col_idx)) + coords.col;
                    if (nr >= 0 and nr < max_x and nc >= 0 and nc < max_y) {
                        const nr_usize: usize = @intCast(nr);
                        const nc_usize: usize = @intCast(nc);
                        if (matrix[nr_usize][nc_usize] == '@') subtotal += 1;
                    }
                }

                if (subtotal < 4) {
                    try to_remove.append(allocator, .{ .row = row_idx, .col = col_idx });
                }
            }
        }

        if (to_remove.items.len > 0) {
            for (to_remove.items) |pos| {
                matrix[pos.row][pos.col] = '.';
                total += 1;
            }
            changed = true;
        }
    }

    std.debug.print("Total rolls of paper collected: {d}\n", .{total});
}

pub fn main() !void {
    const use_test = false;
    try part1(use_test);
    try part2(use_test);
}
