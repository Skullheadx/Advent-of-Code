const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    // Initiate allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    // Read contents from file "./filename"
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(alloc, "day1.txt", 20000);
    defer alloc.free(fileContents);

    // Print file contents
    // std.debug.print("{s}", .{fileContents});
    var splits = std.mem.splitScalar(u8, fileContents, '\n');
    var numZero: i32 = 0;
    var current: i32 = 50;
    while (splits.next()) |chunk| {
        if (chunk.len < 1) {
            continue;
        }
        // std.debug.print("{s}\n", .{chunk[1..]});
        const value = try std.fmt.parseInt(i32, chunk[1..], 10);
        if (chunk[0] == 'L') {
            current = @mod(current - value, 100);
        } else {
            current = @mod(current + value, 100);
        }
        if (current == 0) {
            numZero += 1;
        }
    }
    // Prints to stderr, ignoring potential errors.
    std.debug.print("{}", .{numZero});
    try aoc.bufferedPrint();
}
