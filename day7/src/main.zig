const std = @import("std");
const day7 = @import("day7");

pub fn main() !void {
    // Initiate allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    // Read contents from file "./filename"
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(alloc, "day7.txt", 24000);
    defer alloc.free(fileContents);

    // Print file contents
    // std.debug.print("{s}", .{fileContents});
    var lines = std.mem.splitScalar(u8, fileContents, '\n');

    const firstLine = lines.first();
    const startPos = std.mem.indexOf(u8, firstLine, "S") orelse unreachable;

    var positions = try std.array_list.Aligned(u64, null).initCapacity(alloc, firstLine.len);
    defer positions.deinit(alloc);

    try positions.resize(alloc, firstLine.len);
    @memset(positions.items, 0);

    positions.items[startPos] = 1;

    while (lines.next()) |line| {
        for (line, 0..) |value, i| {
            const position_value = positions.items[i];
            if (value == '^' and position_value > 0) {
                // do left
                positions.items[i - 1] += position_value;
                // right
                positions.items[i + 1] += position_value;

                positions.items[i] -= position_value;
            }
        }
        std.debug.print("{}\n", .{positions});
    }

    var final_result: u64 = 0;
    for (positions.items) |i| {
        final_result += i;
    }
    std.debug.print("result: {}\n", .{final_result});
    try day7.bufferedPrint();
}
