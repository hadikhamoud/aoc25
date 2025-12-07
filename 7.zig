const std = @import("std");
const utils = @import("utils.zig");

const Coords = struct { row: i32, col: i32 };

pub fn part1(use_test: bool) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input_path = if (use_test) "inputs_test/7.txt" else "inputs/7.txt";
    const file_str = try utils.loadFile(input_path, allocator);

    var lines = std.ArrayList([]const u8){};
    defer lines.deinit(allocator);

    var split_iterator = std.mem.splitAny(u8, file_str, "\n");
    while (split_iterator.next()) |line| {
        if (line.len == 0) continue;
        try lines.append(allocator, line);
    }

    const down = Coords{ .row = 1, .col = 0 };
    const down_left = Coords{ .row = 1, .col = -1 };
    const down_right = Coords{ .row = 1, .col = 1 };

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
    const rows: i32 = @intCast(matrix.len);
    const cols: i32 = @intCast(matrix[0].len);
    var elements = std.ArrayList(Coords){};
    defer elements.deinit(allocator);

    for (matrix, 0..) |row, r| {
        for (row, 0..) |_, c| {
            if (matrix[r][c] == 'S') {
                try elements.append(allocator, .{ .row = @intCast(r), .col = @intCast(c) });
                break;
            }
        }
    }

    std.debug.print("start: {d},{d}\n", .{ elements.items[0].row, elements.items[0].col });

    while (elements.items.len > 0) {
        const curr = elements.pop() orelse break;
        const nr = curr.row + down.row;
        const nc = curr.col + down.col;

        if (nr >= 0 and nr < rows and nc >= 0 and nc < cols) {
            const nr_usize: usize = @intCast(nr);
            const nc_usize: usize = @intCast(nc);

            if (matrix[nr_usize][nc_usize] == '|') {
                total -= 1;
                continue;
            } else if (matrix[nr_usize][nc_usize] == '.') {
                try elements.append(allocator, .{ .row = nr, .col = nc });
                matrix[nr_usize][nc_usize] = '|';
            } else if (matrix[nr_usize][nc_usize] == '^') {
                total += 1;
                const nr_dl = curr.row + down_left.row;
                const nc_dl = curr.col + down_left.col;

                const nr_dl_usize: usize = @intCast(nr_dl);
                const nc_dl_usize: usize = @intCast(nc_dl);
                const nr_dr = curr.row + down_right.row;
                const nc_dr = curr.col + down_right.col;

                const nr_dr_usize: usize = @intCast(nr_dr);
                const nc_dr_usize: usize = @intCast(nc_dr);

                if (nr_dl >= 0 and nr_dl < rows and nc_dl >= 0 and nc_dl < cols) {
                    try elements.append(allocator, .{ .row = nr_dl, .col = nc_dl });

                    if (matrix[nr_dl_usize][nc_dl_usize] != '|') {
                        total += 1;
                    }

                    matrix[nr_dl_usize][nc_dl_usize] = '|';
                }

                if (nr_dr >= 0 and nr_dr < rows and nc_dr >= 0 and nc_dr < cols) {
                    try elements.append(allocator, .{ .row = nr_dr, .col = nc_dr });

                    if (matrix[nr_dr_usize][nc_dr_usize] == '|') {
                        total += 1;
                    }
                    matrix[nr_dr_usize][nc_dr_usize] = '|';
                }
            }
        }
    }
    std.debug.print("Total splitters: {d}\n", .{total});
}

fn countTimelinesRecursive(
    matrix: []const []const u8,
    rows: i32,
    cols: i32,
    memo: *std.AutoHashMap(Coords, i64),
    row: i32,
    col: i32,
) !i64 {
    const key = Coords{ .row = row, .col = col };
    if (memo.get(key)) |cached| {
        return cached;
    }

    const next_row = row + 1;
    const next_col = col;

    if (next_row < 0 or next_row >= rows or next_col < 0 or next_col >= cols) {
        try memo.put(key, 1);
        return 1;
    }

    const nr_usize: usize = @intCast(next_row);
    const nc_usize: usize = @intCast(next_col);
    const next_cell = matrix[nr_usize][nc_usize];

    var result: i64 = 0;

    if (next_cell == '.') {
        result = try countTimelinesRecursive(matrix, rows, cols, memo, next_row, next_col);
    } else if (next_cell == '^') {
        const left_row = next_row + 1;
        const left_col = next_col - 1;
        const right_row = next_row + 1;
        const right_col = next_col + 1;

        if (left_row >= 0 and left_row < rows and left_col >= 0 and left_col < cols) {
            result += try countTimelinesRecursive(matrix, rows, cols, memo, left_row, left_col);
        } else {
            result += 1;
        }

        if (right_row >= 0 and right_row < rows and right_col >= 0 and right_col < cols) {
            result += try countTimelinesRecursive(matrix, rows, cols, memo, right_row, right_col);
        } else {
            result += 1;
        }
    } else {
        result = 1;
    }

    try memo.put(key, result);
    return result;
}

pub fn part2(use_test: bool) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input_path = if (use_test) "inputs_test/7.txt" else "inputs/7.txt";
    const file_str = try utils.loadFile(input_path, allocator);

    var lines = std.ArrayList([]const u8){};
    defer lines.deinit(allocator);

    var split_iterator = std.mem.splitAny(u8, file_str, "\n");
    while (split_iterator.next()) |line| {
        if (line.len == 0) continue;
        try lines.append(allocator, line);
    }

    var matrix = try allocator.alloc([]const u8, lines.items.len);
    defer allocator.free(matrix);

    for (lines.items, 0..) |line, i| {
        matrix[i] = line;
    }

    const rows: i32 = @intCast(matrix.len);
    const cols: i32 = @intCast(matrix[0].len);

    var start_row: i32 = 0;
    var start_col: i32 = 0;
    for (matrix, 0..) |row, r| {
        for (row, 0..) |cell, c| {
            if (cell == 'S') {
                start_row = @intCast(r);
                start_col = @intCast(c);
                break;
            }
        }
    }

    var memo = std.AutoHashMap(Coords, i64).init(allocator);
    defer memo.deinit();

    const total = try countTimelinesRecursive(matrix, rows, cols, &memo, start_row, start_col);
    std.debug.print("Total timelines: {d}\n", .{total});
}

pub fn main() !void {
    const use_test = false;
    try part1(use_test);
    try part2(use_test);
}
