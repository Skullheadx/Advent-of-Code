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

// pub fn getLength(n: u64) u64 {
//
//
// }

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
fn getNext(n: []const u8) u64 {
    var n_value = std.fmt.parseInt(u64, n, 10) catch {
        std.debug.panic("invalid integer: '{s}'\n", .{n});
    };
    var n_len: u64 = n.len;
    if (n.len % 2 != 0) {
        n_value = nextPowerOf10(n_value);
        n_len += 1;
    }

    const halfwayMult: u64 = std.math.pow(u64, 10, n_len / 2);

    const firstHalf: u64 = @divFloor(n_value, halfwayMult);
    const secondHalf: u64 = n_value - firstHalf * halfwayMult;

    if (firstHalf > secondHalf) {
        // raise second half
        return firstHalf * halfwayMult + firstHalf;
    } else {
        // raise first half
        const v: u64 = (firstHalf + 1);
        return v * halfwayMult + v;
    }
}

pub fn main() !void {
    // Initiate allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    // Read contents from file "./filename"
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(alloc, "day2_test.txt", 20000);
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
            invalid += start;
        }

        while (val < end) {
            const valStr = try std.fmt.allocPrint(alloc, "{d}", .{val});
            defer alloc.free(valStr); // Remember to free the allocated memory
            val = getNext(valStr);
            if (val < end) {
                invalid += val;
                std.debug.print("{}, ", .{val});
            }
        }
        if (isDouble(endStr)) {
            invalid += end;
        }
        std.debug.print("| invalid:{} \n", .{invalid});
    }
    // Prints to stderr, ignoring potential errors.
    std.debug.print("Sum of invalids: {}\n", .{invalid});
    try day2.bufferedPrint();
}
