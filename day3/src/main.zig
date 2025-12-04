const std = @import("std");
const day3 = @import("day3");

// test "is invalid" {
//     try std.testing.expect(isInvalid("11", 1) == true);
// }

fn getCurrentIndex(arr: [12]u8) usize {
    for (arr, 0..) |v, i| {
        if (v == '0') {
            return i;
        }
    }

    return 12;
}

fn isArr1Bigger(arr1: [12]u8, arr2: [12]u8) bool {
    for (arr1, arr2) |a1, a2| {
        if (a1 > a2) {
            return true;
        } else if (a1 == a2) {
            continue;
        } else if (a1 < a2) {
            return false;
        }
    }
    return true; // they are the same
}

fn addJoltage(arr: [12]u8) u64 {
    var result: u64 = 0;
    for (arr, 0..) |v, i| {
        result += (v - '0') * std.math.pow(u64, 10, 12 - i - 1);
    }
    return result;
}

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
    while (splits.next()) |bank| {
        if (bank.len < 1) {
            continue;
        }
        var stack = std.array_list.Aligned([12]u8, null).empty;
        var managed_stack = stack.toManaged(alloc);
        defer managed_stack.deinit();

        var current_largest: [12]u8 = .{'0'} ** 12;
        try managed_stack.append(current_largest);
        for (bank[0..]) |battery| {
            const l = managed_stack.items.len;
            for (0..l) |current_index| {
                const current_value = managed_stack.items[current_index];
                const c_ind = getCurrentIndex(current_value);
                if (c_ind == 12) {
                    continue;
                }

                var new_curr: [12]u8 = current_value;
                new_curr[c_ind] = battery;
                if (isArr1Bigger(new_curr, current_largest)) {
                    // std.debug.print("bank: {s} current {s}, current_index: {d} current_largest: {s}\n", .{ bank, current_value, c_ind, current_largest });
                    if (c_ind == 11) {
                        current_largest = new_curr;
                    }

                    try managed_stack.append(new_curr);
                }
            }
        }

        for (managed_stack.items) |current_value| {
            const c_ind = getCurrentIndex(current_value);
            if (c_ind == 12) {
                // std.debug.print("current {s}, current_index{d}\n", .{ current_value, c_ind });
                if (isArr1Bigger(current_value, current_largest)) {
                    current_largest = current_value;
                }
            }
        }

        std.debug.print("\ncurrent largest {s}\n", .{current_largest});
        joltage += addJoltage(current_largest);
        std.debug.print("joltage running total {}\n\n", .{joltage});
    }

    std.debug.print("joltage: {}\n", .{joltage});
    try day3.bufferedPrint();
}
