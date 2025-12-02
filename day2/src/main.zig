const std = @import("std");
const day2 = @import("day2");

pub fn nextPowerOf10(n: u64) u64 {
    if (n < 1) {
        return 1;
    }

    var x: u64 = 1;
    while (x < n) {
        x *= 10;
    }
    return x;
}

pub fn getLength(n: u64) u64 {
    if (n < 10) {
        return 1;
    }

    var x: u64 = 1;
    var count: u64 = 1;
    while (x <= n) {
        x *= 10;
        count += 1;
        std.debug.print("{},{}\n", .{ x, count });
    }
    return count - 1;
}

fn isDouble(n: []const u8) bool {
    const n_value: u64 = std.fmt.parseInt(u64, n, 10) catch {
        std.debug.panic("invalid integer: '{s}'\n", .{n});
    };
    const n_len = n.len;
    if (n.len % 2 != 0) {
        return false;
    }

    const halfwayMult: u64 = std.math.pow(u64, 10, n_len / 2);

    const firstHalf: u64 = @divFloor(n_value, halfwayMult);
    const secondHalf: u64 = n_value - firstHalf * halfwayMult;

    if (firstHalf == secondHalf) {
        return true;
    }
    return false;
}

fn getNext(n: u64) u64 {
    var n_len: u64 = getLength(n);
    var n_val: u64 = n;
    if (n_len % 2 != 0) {
        n_val = nextPowerOf10(n);
        n_len += 1;
    }

    const halfwayMult: u64 = std.math.pow(u64, 10, n_len / 2);

    const firstHalf: u64 = @divFloor(n_val, halfwayMult);
    const secondHalf: u64 = n_val - firstHalf * halfwayMult;

    if (firstHalf > secondHalf) {
        // raise second half
        return firstHalf * halfwayMult + firstHalf;
    } else {
        // raise first half
        const v: u64 = firstHalf + 1;
        return v * std.math.pow(u64, 10, getLength(v)) + v;
    }
}

test "getLength" {
    try std.testing.expect(getLength(1) == 1);
    try std.testing.expect(getLength(2) == 1);
    try std.testing.expect(getLength(9) == 1);
    try std.testing.expect(getLength(0) == 1);
    try std.testing.expect(getLength(10) == 2);
    try std.testing.expect(getLength(99) == 2);
    try std.testing.expect(getLength(999) == 3);
    try std.testing.expect(getLength(100) == 3);
    try std.testing.expect(getLength(200) == 3);
}

pub fn main() !void {
    // Initiate allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    // Read contents from file "./filename"
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(alloc, "day2.txt", 20000);
    defer alloc.free(fileContents);

    // Print file contents
    // std.debug.print("{s}", .{fileContents});
    var splits = std.mem.splitScalar(u8, fileContents, ',');
    var invalid: u64 = 0;
    while (splits.next()) |chunk| {
        if (chunk.len < 1) {
            continue;
        }

        const ws = " \t\r\n";
        var it = std.mem.splitScalar(u8, chunk, '-');
        var startStr = it.next() orelse return error.invalid;
        var endStr = it.next() orelse return error.invalid;
        startStr = std.mem.trim(u8, startStr, ws);
        endStr = std.mem.trim(u8, endStr, ws);

        const start = std.fmt.parseInt(u64, startStr, 10) catch {
            std.debug.panic("invalid integer: '{s}'\n", .{startStr});
        };
        const end = std.fmt.parseInt(u64, endStr, 10) catch {
            std.debug.panic("invalid integer: '{s}'\n", .{endStr});
        };

        std.debug.print("start:{} end:{} | ", .{ start, end });
        var val: u64 = start;
        if (isDouble(startStr)) {
            std.debug.print("{}, ", .{start});
            invalid += start;
        }

        while (val < end) {
            val = getNext(val);
            if (val < end) {
                invalid += val;
                std.debug.print("{}, ", .{val});
            }
        }
        if (isDouble(endStr)) {
            std.debug.print("{}, ", .{end});
            invalid += end;
        }
        std.debug.print("| invalid:{} \n", .{invalid});
    }
    // Prints to stderr, ignoring potential errors.
    std.debug.print("Sum of invalids: {}\n", .{invalid});
    try day2.bufferedPrint();
}
