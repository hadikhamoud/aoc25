const std = @import("std");
const utils = @import("utils.zig");

const Coords = struct { x: f64, y: f64, z: f64 };
const Distance = struct {
    a: usize,
    b: usize,
    dist: f64,

    pub fn init(a_idx: usize, b_idx: usize, a: Coords, b: Coords) Distance {
        return Distance{
            .a = a_idx,
            .b = b_idx,
            .dist = computeDistance(a, b),
        };
    }

    pub fn computeDistance(a: Coords, b: Coords) f64 {
        const dx = std.math.pow(f64, a.x - b.x, 2.0);
        const dy = std.math.pow(f64, a.y - b.y, 2.0);
        const dz = std.math.pow(f64, a.z - b.z, 2.0);
        return std.math.sqrt(dx + dy + dz);
    }
};

const DSU = struct {
    parent: []usize,
    size: []usize,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, n: usize) !DSU {
        const parent = try allocator.alloc(usize, n);
        var size = try allocator.alloc(usize, n);

        for (parent, 0..) |*p, i| {
            p.* = i;
            size[i] = 1;
        }

        return DSU{
            .parent = parent,
            .size = size,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *DSU) void {
        self.allocator.free(self.parent);
        self.allocator.free(self.size);
    }

    pub fn find(self: *DSU, x: usize) usize {
        if (self.parent[x] != x) {
            self.parent[x] = self.find(self.parent[x]);
        }
        return self.parent[x];
    }

    pub fn unionSet(self: *DSU, a: usize, b: usize) bool {
        var rootA = self.find(a);
        var rootB = self.find(b);

        if (rootA == rootB) return false;

        if (self.size[rootA] < self.size[rootB]) {
            const tmp = rootA;
            rootA = rootB;
            rootB = tmp;
        }

        self.parent[rootB] = rootA;
        self.size[rootA] += self.size[rootB];
        return true;
    }
};

pub fn part1(use_test: bool) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input_path = if (use_test) "inputs_test/8.txt" else "inputs/8.txt";
    const file_str = try utils.loadFile(input_path, allocator);

    var lines = std.ArrayList([]const u8){};
    defer lines.deinit(allocator);

    var junctions = std.ArrayList(Coords){};
    var distances = std.ArrayList(Distance){};
    defer junctions.deinit(allocator);
    defer distances.deinit(allocator);

    var split_iterator = std.mem.splitSequence(u8, file_str, "\n");
    while (split_iterator.next()) |part| {
        if (part.len < 1) break;
        const split_trimmed = std.mem.trim(u8, part, &std.ascii.whitespace);
        var split_numbers = std.mem.splitSequence(u8, split_trimmed, ",");

        const x_str = split_numbers.next() orelse return error.InvalidRange;
        const y_str = split_numbers.next() orelse return error.InvalidRange;
        const z_str = split_numbers.next() orelse return error.InvalidRange;

        const x = try std.fmt.parseFloat(f64, x_str);
        const y = try std.fmt.parseFloat(f64, y_str);
        const z = try std.fmt.parseFloat(f64, z_str);
        try junctions.append(allocator, Coords{ .x = x, .y = y, .z = z });
    }

    for (0..junctions.items.len - 1) |i| {
        for (i + 1..junctions.items.len) |j| {
            const curr_dist = Distance.init(i, j, junctions.items[i], junctions.items[j]);
            try distances.append(allocator, curr_dist);
        }
    }

    std.mem.sort(Distance, distances.items, {}, struct {
        fn lessThan(_: void, a: Distance, b: Distance) bool {
            return a.dist < b.dist;
        }
    }.lessThan);

    var dsu = try DSU.init(allocator, junctions.items.len);
    defer dsu.deinit();

    const connections_to_make: usize = if (use_test) 10 else 1000;
    for (distances.items[0..connections_to_make]) |d| {
        _ = dsu.unionSet(d.a, d.b);
    }

    var circuit_sizes = std.ArrayList(usize){};
    defer circuit_sizes.deinit(allocator);

    for (0..junctions.items.len) |i| {
        if (dsu.find(i) == i) {
            try circuit_sizes.append(allocator, dsu.size[i]);
        }
    }

    std.mem.sort(usize, circuit_sizes.items, {}, struct {
        fn greaterThan(_: void, a: usize, b: usize) bool {
            return a > b;
        }
    }.greaterThan);

    const result = circuit_sizes.items[0] * circuit_sizes.items[1] * circuit_sizes.items[2];
    std.debug.print("Product of 3 largest circuit sizes: {d}\n", .{result});
}

pub fn part2(use_test: bool) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input_path = if (use_test) "inputs_test/8.txt" else "inputs/8.txt";
    const file_str = try utils.loadFile(input_path, allocator);

    var junctions = std.ArrayList(Coords){};
    var distances = std.ArrayList(Distance){};
    defer junctions.deinit(allocator);
    defer distances.deinit(allocator);

    var split_iterator = std.mem.splitSequence(u8, file_str, "\n");
    while (split_iterator.next()) |part| {
        if (part.len < 1) break;
        const split_trimmed = std.mem.trim(u8, part, &std.ascii.whitespace);
        var split_numbers = std.mem.splitSequence(u8, split_trimmed, ",");

        const x_str = split_numbers.next() orelse return error.InvalidRange;
        const y_str = split_numbers.next() orelse return error.InvalidRange;
        const z_str = split_numbers.next() orelse return error.InvalidRange;

        const x = try std.fmt.parseFloat(f64, x_str);
        const y = try std.fmt.parseFloat(f64, y_str);
        const z = try std.fmt.parseFloat(f64, z_str);
        try junctions.append(allocator, Coords{ .x = x, .y = y, .z = z });
    }

    for (0..junctions.items.len - 1) |i| {
        for (i + 1..junctions.items.len) |j| {
            const curr_dist = Distance.init(i, j, junctions.items[i], junctions.items[j]);
            try distances.append(allocator, curr_dist);
        }
    }

    std.mem.sort(Distance, distances.items, {}, struct {
        fn lessThan(_: void, a: Distance, b: Distance) bool {
            return a.dist < b.dist;
        }
    }.lessThan);

    var dsu = try DSU.init(allocator, junctions.items.len);
    defer dsu.deinit();

    var num_circuits = junctions.items.len;

    for (distances.items) |d| {
        if (dsu.unionSet(d.a, d.b)) {
            num_circuits -= 1;

            if (num_circuits == 1) {
                const x1 = junctions.items[d.a].x;
                const x2 = junctions.items[d.b].x;
                const result = @as(u64, @intFromFloat(x1)) * @as(u64, @intFromFloat(x2));
                std.debug.print("part 2 {d}\n", .{result});
                break;
            }
        }
    }
}

pub fn main() !void {
    const use_test = false;
    try part1(use_test);
    try part2(use_test);
}
