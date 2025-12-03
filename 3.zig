const std = @import("std");
const utils = @import("utils.zig");

fn stringsToDigits(num_str: []const u8, allocator: std.mem.Allocator) ![]u8 {
    var digits = try allocator.alloc(u8, num_str.len);
    for (num_str, 0..) |char, i| {
        digits[i] = char - '0';
    }
    return digits;
}

fn getJoltage(bank_str: []const u8, allocator: std.mem.Allocator) !u8 {
    var max: u8 = 0;
    var max_idx: u8 = 0;
    var second_max: u8 = 0;
    var second_max_idx: u8 = 0;
    const bank = try stringsToDigits(bank_str, allocator);
    if (bank.len == 0) return 0;

    for (bank, 0..) |val, idx| {
        if (val > max) {
            max = val;
            max_idx = @intCast(idx);
        }
    }
    var start: u8 = undefined;
    var end: u8 = undefined;
    if (max_idx == bank.len - 1) {
        start = 0;
        end = max_idx;
    } else {
        start = max_idx + 1;
        end = @intCast(bank.len);
    }

    for (start..end) |i| {
        if (bank[i] >= second_max) {
            second_max = bank[i];
            second_max_idx = @intCast(i);
        }
    }

    if (max_idx < second_max_idx) {
        return max * 10 + second_max;
    } else {
        return second_max * 10 + max;
    }
}

fn getJoltageN(bank_str: []const u8, n: usize, allocator: std.mem.Allocator) !u64 {
    const bank = try stringsToDigits(bank_str, allocator);
    defer allocator.free(bank);

    if (bank.len == 0 or n == 0) return 0;
    if (n >= bank.len) {
        var result: u64 = 0;
        for (bank) |digit| {
            result = result * 10 + digit;
        }
        return result;
    }

    var selected = try allocator.alloc(u8, n);
    defer allocator.free(selected);

    var selected_count: usize = 0;
    var i: usize = 0;

    while (selected_count < n) {
        const remaining_needed = n - selected_count;
        const window_end = bank.len - remaining_needed + 1;
        var max_val: u8 = 0;
        var max_pos: usize = i;

        var j = i;
        while (j < window_end) : (j += 1) {
            if (bank[j] > max_val) {
                max_val = bank[j];
                max_pos = j;
            }
        }

        selected[selected_count] = max_val;
        selected_count += 1;
        i = max_pos + 1;
    }

    var result: u64 = 0;
    for (selected) |digit| {
        result = result * 10 + digit;
    }

    return result;
}

pub fn part1(use_test: bool) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input_path = if (use_test) "inputs_test/3.txt" else "inputs/3.txt";
    const file_str = try utils.loadFile(input_path, allocator);
    var split_iterator = std.mem.splitAny(u8, file_str, "\n");
    var total: i32 = 0;
    while (split_iterator.next()) |part| {
        const joltage = try getJoltage(part, allocator);

        std.debug.print("joltage: {d}\n", .{joltage});

        total = total + joltage;
    }
    std.debug.print("total output joltage: {d}", .{total});
}

pub fn part2(use_test: bool) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input_path = if (use_test) "inputs_test/3.txt" else "inputs/3.txt";
    const file_str = try utils.loadFile(input_path, allocator);
    var split_iterator = std.mem.splitAny(u8, file_str, "\n");
    var total: u64 = 0;
    while (split_iterator.next()) |part| {
        if (part.len == 0) continue;
        const joltage = try getJoltageN(part, 12, allocator);
        std.debug.print("joltage: {d}\n", .{joltage});
        total = total + joltage;
    }
    std.debug.print("total output joltage: {d}\n", .{total});
}

pub fn main() !void {
    const use_test = false;
    try part1(use_test);
    try part2(use_test);
}
