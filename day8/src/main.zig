const std = @import("std");
const day8 = @import("day8");
const Position = struct {
    x: i32,
    y: i32,
    z: i32,
};

fn distSquared(pos1: Position, pos2: Position) i32 {
    return (pos2.x - pos1.x) * (pos2.x - pos1.x) + (pos2.y - pos1.y) * (pos2.y - pos1.y) + (pos2.z - pos1.z) * (pos2.z - pos1.z);
}

pub fn main() !void {
    // Initiate allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    // Read contents from file "./filename"
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(alloc, "day8_test.txt", 24000);
    defer alloc.free(fileContents);

    // Print file contents
    // std.debug.print("{s}", .{fileContents});
    var lines = std.mem.splitScalar(u8, fileContents, '\n');

    var positions = try std.array_list.Aligned(Position, null).empty;
    defer positions.deinit(alloc);

    while (lines.next()) |line| {
        const pos = std.mem.splitScalar(u8, line, ',');
        const xStr = pos.next() orelse unreachable;
        const yStr = pos.next() orelse unreachable;
        const zStr = pos.next() orelse unreachable;

        const x = try std.fmt.parseInt(i32, xStr, 10);
        const y = try std.fmt.parseInt(i32, yStr, 10);
        const z = try std.fmt.parseInt(i32, zStr, 10);
        try positions.append(alloc, Position{ .x = x, .y = y, .z = z });

        // std.debug.print("{}\n", .{positions});
    }

    for (positions.items, 0..) |pos1, i| {
        for (positions.items, 0..) |pos2, j| {
            if (i != j) {}
        }
    }

    var final_result: u64 = 0;
    for (positions.items) |i| {
        final_result += i;
    }
    std.debug.print("result: {}\n", .{final_result});
    try day8.bufferedPrint();
}
