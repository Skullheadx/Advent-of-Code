const std = @import("std");
const day3 = @import("day3");

// test "is invalid" {
//     try std.testing.expect(isInvalid("11", 1) == true);
// }

pub fn main() !void {
    // Initiate allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    // Read contents from file "./filename"
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(alloc, "day3.txt", 24000);
    defer alloc.free(fileContents);

    // Print file contents
    // std.debug.print("{s}", .{fileContents});
    var splits = std.mem.splitScalar(u8, fileContents, '\n');
    var joltage: u64 = 0;
    while (splits.next()) |chunk| {
        if (chunk.len < 1) {
            continue;
        }
        var prev_largest: u8 = 0;
        var prev_largest_second: u8 = 0;
        var largest: u8 = 0;
        var largest_second: u8 = 0;

        for (chunk) |v| {
            if (largest != 0) {
                largest_second = @max(largest_second, v);
            }
            if (v > largest) {
                if (largest_second != 0) {
                    prev_largest = largest;
                    prev_largest_second = largest_second;
                }

                largest = v;
                largest_second = 0;
            }
            std.debug.print("largest:{c} largest_second{c} prev_largest{c} prev_largest_second{c}\n", .{ largest, largest_second, prev_largest, prev_largest_second });
        }

        if (largest_second == 0) {
            largest = prev_largest;
            largest_second = prev_largest_second;
        }

        joltage += (largest - '0') * 10 + (largest_second - '0');
        std.debug.print("joltage running total {}\n\n", .{joltage});
    }

    std.debug.print("joltage: {}\n", .{joltage});
    try day3.bufferedPrint();
}
