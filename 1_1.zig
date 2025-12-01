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
            curr = @mod(curr + incr, 100);
        } else {
            curr = @mod(curr - incr, 100);
        }

        if (curr == 0) {
            password = password + 1;
        }
    }
    std.debug.print("password is {d}", .{password});
}
