const std = @import("std");
const utils = @import("utils.zig");

pub fn part1(use_test: bool) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input_path = if (use_test) "inputs_test/1.txt" else "inputs/1.txt";
    const file_str = try utils.loadFile(input_path, allocator);
    var split_iterator = std.mem.splitAny(u8, file_str, "\n");
    var password: i32 = 0;
    var curr: i32 = 50;
    while (split_iterator.next()) |part| {
        var incr: i32 = undefined;
        if (part.len > 1) {
            incr = try std.fmt.parseInt(i32, part[1..part.len], 10);
        } else {
            break;
        }
        if (part[0] == 'R') {
            curr = @mod(curr + incr, 100);
        } else {
            curr = @mod(curr - incr, 100);
        }

        if (curr == 0) {
            password = password + 1;
        }
    }
    std.debug.print("Part 1 - password is {d}\n", .{password});
}

pub fn part2(use_test: bool) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input_path = if (use_test) "inputs_test/1.txt" else "inputs/1.txt";
    const file_str = try utils.loadFile(input_path, allocator);
    var split_iterator = std.mem.splitAny(u8, file_str, "\n");
    var password: i32 = 0;
    var curr: i32 = 50;
    while (split_iterator.next()) |part| {
        var incr: i32 = undefined;
        if (part.len > 1) {
            incr = try std.fmt.parseInt(i32, part[1..part.len], 10);
        } else {
            break;
        }
        if (part[0] == 'R') {
            password = password + @divFloor(curr + incr, 100);
            curr = @mod(curr + incr, 100);
        } else {
            if (curr > 0) {
                if (incr >= curr) {
                    password = password + @divFloor(incr - curr, 100) + 1;
                }
            } else {
                if (incr >= 100) {
                    password = password + @divFloor(incr - 100, 100) + 1;
                }
            }
            curr = @mod(@mod(curr - incr, 100) + 100, 100);
        }
    }
    std.debug.print("Part 2 - password is {d}\n", .{password});
}

pub fn main() !void {
    const use_test = false;
    try part1(use_test);
    try part2(use_test);
}
