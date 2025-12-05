const std = @import("std");
const day4 = @import("day4");

test "idx test" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    // Read contents from file "./filename"
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(alloc, "day4_test.txt", 24000);
    defer alloc.free(fileContents);

    // Print file contents
    // std.debug.print("{s}", .{fileContents});
    var lines = std.mem.splitScalar(u8, fileContents, '\n');

    const line = lines.peek() orelse unreachable;
    const col_count = line.len;

    var grid = std.array_list.Aligned(bool, null).empty;
    defer grid.deinit(alloc);

    // put in all @
    var r: u64 = 0;
    while (lines.next()) |row| : (r += 1) {
        if (row.len == 0) {
            break;
        }
        std.debug.print("row: {s}\n", .{row});
        for (row) |v| {
            if (v == '@') {
                try grid.append(alloc, true);
            } else {
                try grid.append(alloc, false);
            }
        }
    }

    // const row_count = r / col_count;
    try std.testing.expect(grid.items[idx(0, 0, col_count)] == false);
    try std.testing.expect(grid.items[idx(0, 1, col_count)] == false);
    try std.testing.expect(grid.items[idx(0, 2, col_count)] == true);
    try std.testing.expect(grid.items[idx(0, 3, col_count)] == true);
    try std.testing.expect(grid.items[idx(0, 4, col_count)] == false);
    try std.testing.expect(grid.items[idx(0, 5, col_count)] == true);
    try std.testing.expect(grid.items[idx(0, 6, col_count)] == true);
    try std.testing.expect(grid.items[idx(0, 7, col_count)] == true);
    try std.testing.expect(grid.items[idx(0, 8, col_count)] == true);
    try std.testing.expect(grid.items[idx(0, 9, col_count)] == false);

    try std.testing.expect(grid.items[idx(1, 0, col_count)] == true);
    try std.testing.expect(grid.items[idx(1, 1, col_count)] == true);
    try std.testing.expect(grid.items[idx(1, 2, col_count)] == true);
    try std.testing.expect(grid.items[idx(1, 3, col_count)] == false);
    try std.testing.expect(grid.items[idx(1, 4, col_count)] == true);
    try std.testing.expect(grid.items[idx(1, 5, col_count)] == false);
    try std.testing.expect(grid.items[idx(1, 6, col_count)] == true);
    try std.testing.expect(grid.items[idx(1, 7, col_count)] == false);
    try std.testing.expect(grid.items[idx(1, 8, col_count)] == true);
    try std.testing.expect(grid.items[idx(1, 9, col_count)] == true);
}

const Position = struct {
    row: u64,
    col: u64,
};

fn idx(r: usize, c: usize, col_count: usize) usize {
    return r * col_count + c;
}

const MAX_POTENTIAL_CHANGES = 8;
const AppendError = error{Full};
fn append(arr: *[MAX_POTENTIAL_CHANGES]Position, arr_len: *usize, val: Position) (AppendError!void) {
    if (arr_len.* >= arr.*.len) {
        return error.Full;
    }
    arr[arr_len.*] = val;
    arr_len.* += 1;
}

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
    var lines = std.mem.splitScalar(u8, fileContents, '\n');

    const line = lines.peek() orelse unreachable;
    const col_count = line.len;

    var accessible_rolls: u64 = 0;
    var changes = std.array_list.Aligned(Position, null).empty;
    defer changes.deinit(alloc);

    var grid = std.array_list.Aligned(bool, null).empty;
    defer grid.deinit(alloc);

    var next_grid = std.array_list.Aligned(bool, null).empty;
    defer next_grid.deinit(alloc);

    // put in all @
    var r: u64 = 0;
    while (lines.next()) |row| : (r += 1) {
        if (row.len == 0) {
            break;
        }
        std.debug.print("row: {s}\n", .{row});
        for (row, 0..) |v, c| {
            if (v == '@') {
                try changes.append(alloc, Position{ .row = r, .col = c });
                try grid.append(alloc, true);
            } else {
                try grid.append(alloc, false);
            }
        }
    }

    const row_count = r;

    try next_grid.resize(alloc, grid.items.len);
    @memcpy(next_grid.items, grid.items);

    var current_head: usize = 0;
    var changes_made = true;
    std.debug.print("COL_COUNT:{}, ROW_COUNT:{}\n\n\n", .{ col_count, row_count });

    var seen = std.hash_map.AutoHashMap(Position, bool).init(alloc);
    defer seen.deinit();

    while (changes_made) {
        for (grid.items, 0..) |value, j| {
            if (j % col_count == 0 and j != 0) {
                std.debug.print("\n", .{});
            }
            if (value) {
                std.debug.print("@", .{});
            } else {
                std.debug.print(".", .{});
            }
        }
        std.debug.print("\n", .{});
        const current_changes_len = changes.items.len;
        for (current_head..current_changes_len) |i| {
            const pos = changes.items[i];
            if (seen.get(pos) orelse false) {
                continue;
            }
            var potential_changes: [MAX_POTENTIAL_CHANGES]Position = undefined;
            var potential_changes_len: usize = 0;
            std.debug.print("index: i{}, current head{} current_changes_len{} | ", .{ i, current_head, current_changes_len });
            std.debug.print("Position: [{}, {}] idx{} | ", .{ pos.row, pos.col, idx(pos.row, pos.col, col_count) });
            // if (!grid.items[idx(pos.row, pos.col, col_count)]) {
            //     continue;
            // }
            var surrounding: u64 = 0;
            if (pos.row > 0) {
                if (pos.col > 0) {
                    if (grid.items[idx(pos.row - 1, pos.col - 1, col_count)]) {
                        surrounding += 1;
                        try append(&potential_changes, &potential_changes_len, Position{ .row = pos.row - 1, .col = pos.col - 1 });
                    }
                }
                if (grid.items[idx(pos.row - 1, pos.col, col_count)]) {
                    surrounding += 1;
                    try append(&potential_changes, &potential_changes_len, Position{ .row = pos.row - 1, .col = pos.col });
                }
                if (pos.col + 1 < col_count) {
                    if (grid.items[idx(pos.row - 1, pos.col + 1, col_count)]) {
                        surrounding += 1;
                        try append(&potential_changes, &potential_changes_len, Position{ .row = pos.row - 1, .col = pos.col + 1 });
                    }
                }
            }
            if (pos.col > 0) {
                if (grid.items[idx(pos.row, pos.col - 1, col_count)]) {
                    surrounding += 1;
                    try append(&potential_changes, &potential_changes_len, Position{ .row = pos.row, .col = pos.col - 1 });
                }
            }
            if (pos.col + 1 < col_count) {
                if (grid.items[idx(pos.row, pos.col + 1, col_count)]) {
                    surrounding += 1;
                    try append(&potential_changes, &potential_changes_len, Position{ .row = pos.row, .col = pos.col + 1 });
                }
            }
            if (pos.row + 1 < row_count) {
                if (pos.col > 0) {
                    if (grid.items[idx(pos.row + 1, pos.col - 1, col_count)]) {
                        surrounding += 1;
                        try append(&potential_changes, &potential_changes_len, Position{ .row = pos.row + 1, .col = pos.col - 1 });
                    }
                }
                if (grid.items[idx(pos.row + 1, pos.col, col_count)]) {
                    surrounding += 1;
                    try append(&potential_changes, &potential_changes_len, Position{ .row = pos.row + 1, .col = pos.col });
                }
                if (pos.col + 1 < col_count) {
                    if (grid.items[idx(pos.row + 1, pos.col + 1, col_count)]) {
                        surrounding += 1;
                        try append(&potential_changes, &potential_changes_len, Position{ .row = pos.row + 1, .col = pos.col + 1 });
                    }
                }
            }
            if (surrounding < 4) {
                accessible_rolls += 1;
                next_grid.items[idx(pos.row, pos.col, col_count)] = false;
                std.debug.print("(r:{}, c:{}) surrounding: {}", .{ pos.row, pos.col, surrounding });
                const potential_changes_slice = potential_changes[0..potential_changes_len];
                try changes.appendSlice(alloc, potential_changes_slice);
                try seen.put(pos, true);
            }
            std.debug.print("\n", .{});
        }

        std.debug.print("\n rolls: {}\n\n", .{accessible_rolls});
        if (changes.items.len == current_changes_len) {
            changes_made = false;
        }
        current_head = current_changes_len;
        @memcpy(grid.items, next_grid.items);
        // return;
    }

    std.debug.print("accessible rolls: {}\n", .{accessible_rolls});
    try day4.bufferedPrint();
}
