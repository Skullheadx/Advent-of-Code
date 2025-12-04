const std = @import("std");
const day4 = @import("day4");

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
    const fileContents = try cwd.readFileAlloc(alloc, "day4.txt", 24000);
    defer alloc.free(fileContents);

    // Print file contents
    // std.debug.print("{s}", .{fileContents});
    var splits = std.mem.splitScalar(u8, fileContents, '\n');

    var accessible_rolls: u64 = 0;
    const line = splits.peek() orelse return;
    const len: usize = line.len;
    std.debug.assert(len > 0);
    var prev = try std.array_list.Aligned(u8, null).initCapacity(alloc, len);
    var next = try std.array_list.Aligned(u8, null).initCapacity(alloc, len);
    defer prev.deinit(alloc);
    defer next.deinit(alloc);

    try prev.resize(alloc, len);
    try next.resize(alloc, len);

    @memset(prev.items, '.');
    @memset(next.items, '.');
    // std.debug.print("prev items{s}\n\n", .{prev.items});
    // std.debug.print("next items{s}\n\n", .{next.items});
    var ind: u64 = 0;
    while (splits.next()) |row| {
        // std.debug.print("split: {s}\n", .{row});
        if (row.len < 1) {
            ind += 1;
            continue;
        }
        if (splits.peek()) |next_line| {
            // std.debug.print("next_line len={} hex={s}\n", .{ next_line.len, next_line });

            if (next_line.len > 0) {
                @memcpy(next.items[0..next_line.len], next_line);
            } else {
                @memset(next.items, '.');
            }
        } else {
            @memset(next.items, '.');
        }

        std.debug.print("prev: {s}\nrow:  {s}\nnext: {s}\n", .{ prev.items, row, next.items });
        for (0..len) |i| {
            if (row[i] != '@') {
                continue;
            }
            var surround: u64 = 0;
            if (i > 0) { // left
                if (prev.items[i - 1] == '@') {
                    surround += 1;
                    std.debug.print("i={}, src=prev_left, surround now={}\n", .{ i, surround });
                }
                if (row[i - 1] == '@') {
                    surround += 1;
                    std.debug.print("i={}, src=row_left, surround now={}\n", .{ i, surround });
                }
                if (next.items[i - 1] == '@') {
                    surround += 1;
                    std.debug.print("i={}, src=next_left, surround now={}\n", .{ i, surround });
                }
            }
            if (prev.items[i] == '@') {
                surround += 1;
                std.debug.print("i={}, src=prev_mid, surround now={}\n", .{ i, surround });
            }
            if (next.items[i] == '@') {
                surround += 1;
                std.debug.print("i={}, src=next_mid, surround now={}\n", .{ i, surround });
            }
            if (i < row.len - 1) { // right
                if (prev.items[i + 1] == '@') {
                    surround += 1;
                    std.debug.print("i={}, src=prev_right, surround now={}\n", .{ i, surround });
                }
                if (row[i + 1] == '@') {
                    surround += 1;
                    std.debug.print("i={}, src=row_right, surround now={}\n", .{ i, surround });
                }
                if (next.items[i + 1] == '@') {
                    surround += 1;
                    std.debug.print("i={}, src=next_right, surround now={}\n", .{ i, surround });
                }
            }
            std.debug.print("surround: {}, ", .{surround});
            if (surround < 4) {
                accessible_rolls += 1;
            }
            ind += 1;
        }
        std.debug.assert(prev.items.len == row.len);
        @memcpy(prev.items, row);
        std.debug.print("rolls running total {}\n\n", .{accessible_rolls});
    }

    std.debug.print("accessible rolls: {}\n", .{accessible_rolls});
    try day4.bufferedPrint();
}
