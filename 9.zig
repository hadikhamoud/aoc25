const std = @import("std");
const utils = @import("utils.zig");

const Point = struct { x: usize, y: usize };

fn getArea(a: Point, b: Point) usize {
    const dx = if (a.x > b.x) a.x - b.x else b.x - a.x;
    const dy = if (a.y > b.y) a.y - b.y else b.y - a.y;
    return (dx + 1) * (dy + 1);
}

pub fn part1(use_test: bool) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input_path = if (use_test) "inputs_test/9.txt" else "inputs/9.txt";
    const file_str = try utils.loadFile(input_path, allocator);
    var split_iterator = std.mem.splitAny(u8, file_str, "\n");

    var points = std.ArrayList(Point){};
    defer points.deinit(allocator);

    while (split_iterator.next()) |part| {
        var point_iterator = std.mem.splitSequence(u8, part, ",");
        if (part.len < 1) break;
        const x_str = point_iterator.next() orelse return error.InvalidRange;
        const y_str = point_iterator.next() orelse return error.InvalidRange;
        const x = try std.fmt.parseInt(usize, x_str, 10);
        const y = try std.fmt.parseInt(usize, y_str, 10);

        const point = Point{ .x = x, .y = y };
        try points.append(allocator, point);
    }

    var max: usize = 0;

    for (0..points.items.len - 1) |i| {
        for (i + 1..points.items.len) |j| {
            const area = getArea(points.items[i], points.items[j]);
            if (area >= max) max = area;
        }
    }

    std.debug.print("max {d}", .{max});
}

fn isInsidePolygon(point: Point, polygon: []Point) bool {
    var inside = false;
    var j = polygon.len - 1;

    for (0..polygon.len) |i| {
        const xi = @as(i64, @intCast(polygon[i].x));
        const yi = @as(i64, @intCast(polygon[i].y));
        const xj = @as(i64, @intCast(polygon[j].x));
        const yj = @as(i64, @intCast(polygon[j].y));
        const px = @as(i64, @intCast(point.x));
        const py = @as(i64, @intCast(point.y));

        if (((yi > py) != (yj > py)) and (px < @divTrunc((xj - xi) * (py - yi), (yj - yi)) + xi)) {
            inside = !inside;
        }
        j = i;
    }

    return inside;
}

fn isOnPolygonEdge(point: Point, polygon: []Point) bool {
    for (polygon) |p| {
        if (p.x == point.x and p.y == point.y) return true;
    }

    for (0..polygon.len) |i| {
        const p1 = polygon[i];
        const p2 = polygon[(i + 1) % polygon.len];

        if (p1.y == p2.y and p1.y == point.y) {
            const min_x = @min(p1.x, p2.x);
            const max_x = @max(p1.x, p2.x);
            if (point.x >= min_x and point.x <= max_x) return true;
        }

        if (p1.x == p2.x and p1.x == point.x) {
            const min_y = @min(p1.y, p2.y);
            const max_y = @max(p1.y, p2.y);
            if (point.y >= min_y and point.y <= max_y) return true;
        }
    }

    return false;
}

fn lineSegmentsIntersect(p1: Point, p2: Point, p3: Point, p4: Point) bool {
    const x1 = @as(i64, @intCast(p1.x));
    const y1 = @as(i64, @intCast(p1.y));
    const x2 = @as(i64, @intCast(p2.x));
    const y2 = @as(i64, @intCast(p2.y));
    const x3 = @as(i64, @intCast(p3.x));
    const y3 = @as(i64, @intCast(p3.y));
    const x4 = @as(i64, @intCast(p4.x));
    const y4 = @as(i64, @intCast(p4.y));

    const denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if (denom == 0) return false;

    const t = @divTrunc((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4), denom);
    const u = @divTrunc((x1 - x3) * (y1 - y2) - (y1 - y3) * (x1 - x2), denom);

    return (t > 0 and t < 1) and (u > 0 and u < 1);
}

fn isRectangleValid(a: Point, b: Point, polygon: []Point) bool {
    const min_x = @min(a.x, b.x);
    const max_x = @max(a.x, b.x);
    const min_y = @min(a.y, b.y);
    const max_y = @max(a.y, b.y);

    for (polygon) |vertex| {
        if ((vertex.x == a.x and vertex.y == a.y) or (vertex.x == b.x and vertex.y == b.y)) {
            continue;
        }

        if (vertex.x > min_x and vertex.x < max_x and vertex.y > min_y and vertex.y < max_y) {
            return false;
        }
    }

    for (0..polygon.len) |i| {
        const p1 = polygon[i];
        const p2 = polygon[(i + 1) % polygon.len];

        const rect_edges = [_][2]Point{
            [_]Point{ Point{ .x = min_x, .y = min_y }, Point{ .x = max_x, .y = min_y } },
            [_]Point{ Point{ .x = max_x, .y = min_y }, Point{ .x = max_x, .y = max_y } },
            [_]Point{ Point{ .x = max_x, .y = max_y }, Point{ .x = min_x, .y = max_y } },
            [_]Point{ Point{ .x = min_x, .y = max_y }, Point{ .x = min_x, .y = min_y } },
        };

        for (rect_edges) |edge| {
            if (lineSegmentsIntersect(p1, p2, edge[0], edge[1])) {
                return false;
            }
        }
    }

    const corners = [_]Point{
        Point{ .x = min_x, .y = min_y },
        Point{ .x = min_x, .y = max_y },
        Point{ .x = max_x, .y = min_y },
        Point{ .x = max_x, .y = max_y },
    };

    for (corners) |corner| {
        const is_inside = isInsidePolygon(corner, polygon);
        const is_on_edge = isOnPolygonEdge(corner, polygon);
        if (!is_inside and !is_on_edge) {
            return false;
        }
    }

    var x = min_x;
    while (x <= max_x) : (x += @max(1, (max_x - min_x) / 100)) {
        const top = Point{ .x = x, .y = min_y };
        const bottom = Point{ .x = x, .y = max_y };

        if (!isInsidePolygon(top, polygon) and !isOnPolygonEdge(top, polygon)) {
            return false;
        }
        if (!isInsidePolygon(bottom, polygon) and !isOnPolygonEdge(bottom, polygon)) {
            return false;
        }
    }

    var y = min_y;
    while (y <= max_y) : (y += @max(1, (max_y - min_y) / 100)) {
        const left = Point{ .x = min_x, .y = y };
        const right = Point{ .x = max_x, .y = y };

        if (!isInsidePolygon(left, polygon) and !isOnPolygonEdge(left, polygon)) {
            return false;
        }
        if (!isInsidePolygon(right, polygon) and !isOnPolygonEdge(right, polygon)) {
            return false;
        }
    }

    return true;
}

pub fn part2(use_test: bool) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input_path = if (use_test) "inputs_test/9.txt" else "inputs/9.txt";
    const file_str = try utils.loadFile(input_path, allocator);
    var split_iterator = std.mem.splitAny(u8, file_str, "\n");

    var points = std.ArrayList(Point){};
    defer points.deinit(allocator);

    while (split_iterator.next()) |part| {
        var point_iterator = std.mem.splitSequence(u8, part, ",");
        if (part.len < 1) break;
        const x_str = point_iterator.next() orelse return error.InvalidRange;
        const y_str = point_iterator.next() orelse return error.InvalidRange;
        const x = try std.fmt.parseInt(usize, x_str, 10);
        const y = try std.fmt.parseInt(usize, y_str, 10);

        const point = Point{ .x = x, .y = y };
        try points.append(allocator, point);
    }

    var max: usize = 0;

    for (0..points.items.len - 1) |i| {
        for (i + 1..points.items.len) |j| {
            if (isRectangleValid(points.items[i], points.items[j], points.items)) {
                const area = getArea(points.items[i], points.items[j]);
                if (area > max) max = area;
            }
        }
    }

    std.debug.print("max {d}\n", .{max});
}

pub fn main() !void {
    const use_test = false;
    //try part1(use_test);
    try part2(use_test);
}
