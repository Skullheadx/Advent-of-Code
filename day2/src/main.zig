const std = @import("std");
const day2 = @import("day2");

fn isInvalid(str: []const u8, substr_len: u64) bool {
    const substr = str[0..substr_len];
    var i: u64 = 0;
    while (i < str.len) {
        if (i + substr_len > str.len) {
            return false;
        }
        if (!std.mem.eql(u8, substr, str[i .. i + substr_len])) {
            return false;
        }
        i += substr_len;
    }
    return true;
}

test "is invalid" {
    try std.testing.expect(isInvalid("11", 1) == true);
    try std.testing.expect(isInvalid("22", 1) == true);
    try std.testing.expect(isInvalid("1010", 2) == true);
    try std.testing.expect(isInvalid("1010", 1) == false);
    try std.testing.expect(isInvalid("12341234", 1) == false);
    try std.testing.expect(isInvalid("12341234", 2) == false);
    try std.testing.expect(isInvalid("12341234", 3) == false);
    try std.testing.expect(isInvalid("12341234", 4) == true);
    try std.testing.expect(isInvalid("123123123", 1) == false);
    try std.testing.expect(isInvalid("123123123", 2) == false);
    try std.testing.expect(isInvalid("123123123", 3) == true);
    try std.testing.expect(isInvalid("123123123", 4) == false);
    try std.testing.expect(isInvalid("123123123", 5) == false);
    try std.testing.expect(isInvalid("111", 1) == true);
    try std.testing.expect(isInvalid("111", 2) == false);
    try std.testing.expect(isInvalid("1212121212", 1) == false);
    try std.testing.expect(isInvalid("1212121212", 2) == true);
    try std.testing.expect(isInvalid("1212121212", 3) == false);
    try std.testing.expect(isInvalid("1111111", 1) == true);
    try std.testing.expect(isInvalid("1111111", 2) == false);
}

fn numDigits(x: u64) usize {
    if (x == 0) {
        return 1;
    }
    return std.math.log10_int(x) + 1;
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
        for (start..end + 1) |i| {
            // std.debug.print("i:{} | ", .{i});
            for (1..@divTrunc(numDigits(i), 2) + 1) |j| {
                // std.debug.print("j:{} ; ", .{j});
                const str = try std.fmt.allocPrint(
                    alloc,
                    "{d}",
                    .{i},
                );
                defer alloc.free(str);
                if (isInvalid(str, j)) {
                    invalid += i;
                    std.debug.print("{}, ", .{i});
                    break;
                }
            }
        }
        std.debug.print("| invalid:{} \n", .{invalid});
    }
    // Prints to stderr, ignoring potential errors.
    std.debug.print("Sum of invalids: {}\n", .{invalid});
    try day2.bufferedPrint();
}
