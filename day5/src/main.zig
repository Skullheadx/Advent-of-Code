const std = @import("std");
const day5 = @import("day5");

const Range = struct {
    start: u64,
    end: u64,
};

fn isFresh(ranges: *std.array_list.Aligned, value: u64) bool {
    for (ranges.*.items) |r| {
        if (r.start <= value and value <= r.end) {
            return true;
        }
    }
    return false;
}

fn lessThenByStart(_: void, a: Range, b: Range) bool {
    return a.start < b.start; // ascending
}

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

    std.sort.block(Range, fresh_ranges.items, {}, lessThenByStart);

    var real_ranges = std.array_list.Aligned(Range, null).empty;
    defer real_ranges.deinit(alloc);

    const first_ele = fresh_ranges.items[0];
    var current_start = first_ele.start;
    var current_end = first_ele.end;
    for (fresh_ranges.items) |fr| {
        const start = fr.start;
        const end = fr.end;
        if (start <= current_end) {
            current_end = @max(current_end, end);
            continue;
        } else {
            try real_ranges.append(alloc, Range{ .start = current_start, .end = current_end });
            current_end = end;
            current_start = start;
        }
    }
    try real_ranges.append(alloc, Range{ .start = current_start, .end = current_end });

    for (real_ranges.items) |rr| {
        std.debug.print("start:{}, end:{}\n", .{ rr.start, rr.end });
        fresh += rr.end - rr.start + 1;
    }

    std.debug.print("fresh: {}\n", .{fresh});
    try day5.bufferedPrint();
}
