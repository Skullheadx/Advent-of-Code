const std = @import("std");
const day5 = @import("day5");

const Range = struct {
    start: u64,
    end: u64,
};

pub fn main() !void {
    // Initiate allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    // Read contents from file "./filename"
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(alloc, "day5.txt", 24000);
    defer alloc.free(fileContents);

    // Print file contents
    // std.debug.print("{s}", .{fileContents});
    var lines = std.mem.splitScalar(u8, fileContents, '\n');

    var fresh: u64 = 0;

    var fresh_ranges = std.array_list.Aligned(Range, null).empty;
    defer fresh_ranges.deinit(alloc);

    while (lines.next()) |row| {
        if (row.len == 0) { // break between ranges and values
            break;
        }
        var r = std.mem.splitScalar(u8, row, '-');

        const sStr = r.next() orelse unreachable;
        const eStr = r.next() orelse unreachable;

        const s: u64 = try std.fmt.parseInt(u64, sStr, 10);
        const e: u64 = try std.fmt.parseInt(u64, eStr, 10);

        try fresh_ranges.append(alloc, Range{ .start = s, .end = e });
    }

    while (lines.next()) |row| {
        if (row.len == 0) {
            break;
        }
        const value = try std.fmt.parseInt(u64, row, 10);

        for (fresh_ranges.items) |r| {
            if (r.start <= value and value <= r.end) {
                std.debug.print("fresh: {} | ", .{value});
                fresh += 1;
                break;
            }
        }
        std.debug.print("{}\n", .{value});
    }

    std.debug.print("fresh: {}\n", .{fresh});
    try day5.bufferedPrint();
}
