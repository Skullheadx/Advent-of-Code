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

    var positions = try std.array_list.Aligned(u32, null).initCapacity(alloc, firstLine.len);
    defer positions.deinit(alloc);

    try positions.resize(alloc, firstLine.len);
    @memset(positions.items, 0);

    positions.items[startPos] = 1;

    var final_result: u64 = 0;
    while (lines.next()) |line| {
        for (line, 0..) |value, i| {
            if (value == '^') {
                if (positions.items[i] > 0) {
                    // do left
                    if (positions.items[i - 1] == 0) {
                        positions.items[i - 1] = 1;
                    }
                    // right
                    if (positions.items[i + 1] == 0) {
                        positions.items[i + 1] = 1;
                    }

                    positions.items[i] = 0;
                    final_result += 1;
                }
            }
        }
    }

    std.debug.print("result: {}\n", .{final_result});
    try day7.bufferedPrint();
}
