const std = @import("std");
const utils = @import("utils.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const file_str = try utils.loadFile("input_1_1.txt", allocator);
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
    std.debug.print("password is {d}", .{password});
}
