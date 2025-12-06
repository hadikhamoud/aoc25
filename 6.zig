const std = @import("std");
const utils = @import("utils.zig");

pub fn part1(use_test: bool) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input_path = if (use_test) "inputs_test/6.txt" else "inputs/6.txt";
    const file_str = try utils.loadFile(input_path, allocator);

    var lines = std.ArrayList([]const u8){};
    defer lines.deinit(allocator);
    const delimiter_set = " \t\n\r";

    var split_iterator = std.mem.splitAny(u8, file_str, "\n");
    const ops1 = split_iterator.next() orelse return error.InvalidRange;
    const ops2 = split_iterator.next() orelse return error.InvalidRange;
    const ops3 = split_iterator.next() orelse return error.InvalidRange;
    const ops4 = split_iterator.next() orelse return error.InvalidRange;
    const opers = split_iterator.next() orelse return error.InvalidRange;

    var total: i64 = 0;

    var ops1_lst = std.mem.tokenizeAny(u8, ops1, delimiter_set);
    var ops2_lst = std.mem.tokenizeAny(u8, ops2, delimiter_set);
    var ops3_lst = std.mem.tokenizeAny(u8, ops3, delimiter_set);
    var ops4_lst = std.mem.tokenizeAny(u8, ops4, delimiter_set);
    var opers_lst = std.mem.tokenizeAny(u8, opers, delimiter_set);

    while (ops1_lst.next()) |op1| {
        const op2 = ops2_lst.next() orelse break;
        const op3 = ops3_lst.next() orelse break;
        const op4 = ops4_lst.next() orelse break;
        const oper = opers_lst.next() orelse break;
        const op1_int = try std.fmt.parseInt(i64, op1, 10);
        const op2_int = try std.fmt.parseInt(i64, op2, 10);
        const op3_int = try std.fmt.parseInt(i64, op3, 10);
        const op4_int = try std.fmt.parseInt(i64, op4, 10);

        if (std.mem.eql(u8, oper, "*")) {
            total += op1_int * op2_int * op3_int * op4_int;
        } else if (std.mem.eql(u8, oper, "+")) total += op1_int + op2_int + op3_int + op4_int;
    }
    std.debug.print("homework answer is: {d}", .{total});
}

fn part2(use_test: bool) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input_path = if (use_test) "inputs_test/6.txt" else "inputs/6.txt";
    const file_str = try utils.loadFile(input_path, allocator);

    var split_iterator = std.mem.splitAny(u8, file_str, "\n");
    var lines = std.ArrayList([]const u8){};
    defer lines.deinit(allocator);

    while (split_iterator.next()) |line| {
        if (line.len == 0) break;
        try lines.append(allocator, line);
    }

    const opers = lines.pop() orelse return error.InvalidRange;

    var i: usize = lines.items[0].len - 1;

    var ops = std.ArrayList(i32){};
    defer ops.deinit(allocator);
    var total: i64 = 0;

    while (i >= 0) : (i -= 1) {
        var buffer = try allocator.alloc(u8, lines.items[0].len);

        defer allocator.free(buffer);
        var j: usize = 0;
        for (lines.items) |line| {
            if (line[i] == ' ') continue;
            buffer[j] = line[i];
            j += 1;
        }

        if (j == 0) continue;
        const buffer_int = try std.fmt.parseInt(i32, buffer[0..j], 10);
        try ops.append(allocator, buffer_int);

        if (opers[i] == '*') {
            var subtotal: i64 = 1;
            for (ops.items) |val| {
                subtotal *= val;
            }
            total += subtotal;
            ops.clearRetainingCapacity();

            if (i == 0) break;
        }

        if (opers[i] == '+') {
            var subtotal: i64 = 0;
            for (ops.items) |val| {
                subtotal += val;
            }
            total += subtotal;
            ops.clearRetainingCapacity();

            if (i == 0) break;
        }
    }

    std.debug.print("homework answer is: {d}", .{total});
}

pub fn main() !void {
    const use_test = false;
    try part1(use_test);
    try part2(use_test);
}
