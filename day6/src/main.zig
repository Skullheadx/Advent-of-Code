const std = @import("std");
const day6 = @import("day6");

test "max length" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(alloc, "day6.txt", 24000);
    defer alloc.free(fileContents);

    var lines = std.mem.splitScalar(u8, fileContents, '\n');

    var max_col_len: usize = 0;
    var max_row_len: usize = 0;

    while (lines.next()) |row| {
        if (row.len == 0) {
            break;
        }
        var r = std.mem.splitScalar(u8, row, ' ');
        while (r.next()) |c| {
            std.debug.print("Max_len:{}, c:{s}, c.len:{}\n", .{ max_col_len, c, c.len });
            max_col_len = @max(max_col_len, c.len);
        }
        max_row_len = @max(max_row_len, row.len);
    }

    std.debug.print("Max col len: {}\n", .{max_col_len}); // 4
    std.debug.print("Max row len: {}\n", .{max_row_len}); // 3745
}

pub fn main() !void {
    // Initiate allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    // Read contents from file "./filename"
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(alloc, "day6.txt", 24000);
    defer alloc.free(fileContents);

    var numbers = std.array_list.Aligned([]const u8, null).empty;
    defer numbers.deinit(alloc);
    // Print file contents
    // std.debug.print("{s}", .{fileContents});
    var lines = std.mem.splitScalar(u8, fileContents, '\n');

    var final_result: u64 = 0;

    while (lines.next()) |row| {
        if (row.len == 0) { // break between ranges and values
            break;
        }
        try numbers.append(alloc, row);
    }

    var current_operator_index: usize = 0;
    for (numbers.items[numbers.items.len - 1][1..], 1..) |next_char, i| {
        if (next_char != ' ') {
            const operator: u8 = numbers.items[numbers.items.len - 1][current_operator_index];
            var result: u64 = 0;
            if (operator == '*') {
                result = 1;
            }
            std.debug.print("before result:|{}|\n", .{result});
            for (current_operator_index..i - 1) |j| { //cols
                var current_nums = try std.array_list.Aligned(u8, null).initCapacity(alloc, numbers.items.len - 1);
                defer current_nums.deinit(alloc);
                for (0..numbers.items.len - 1) |k| { //rows
                    try current_nums.append(alloc, numbers.items[k][j]);
                }
                const current_num_str = std.mem.trim(u8, current_nums.items, " ");
                std.debug.print("str:|{s}|\n", .{current_num_str});
                const current_num = try std.fmt.parseInt(u64, current_num_str, 10);
                if (operator == '+') {
                    result += current_num;
                } else {
                    result *= current_num;
                }
            }
            std.debug.print("result:|{}|\n", .{result});
            final_result += result;

            current_operator_index = i;
        }
    }
    {
        const operator: u8 = numbers.items[numbers.items.len - 1][current_operator_index];
        var result: u64 = 0;
        if (operator == '*') {
            result = 1;
        }
        std.debug.print("before result:|{}|\n", .{result});
        for (current_operator_index..numbers.items[numbers.items.len - 1].len) |j| { //cols
            var current_nums = try std.array_list.Aligned(u8, null).initCapacity(alloc, numbers.items.len - 1);
            defer current_nums.deinit(alloc);
            for (0..numbers.items.len - 1) |k| { //rows
                try current_nums.append(alloc, numbers.items[k][j]);
            }
            const current_num_str = std.mem.trim(u8, current_nums.items, " ");
            std.debug.print("str:|{s}|\n", .{current_num_str});
            const current_num = try std.fmt.parseInt(u64, current_num_str, 10);
            if (operator == '+') {
                result += current_num;
            } else {
                result *= current_num;
            }
        }
        std.debug.print("result:|{}|\n", .{result});
        final_result += result;
    }

    // var r = std.mem.splitScalar(u8, row, ' ');
    // var i: usize = 0;
    // while (r.next()) |value| {
    //     if (value.len == 0) {
    //         continue;
    //     }
    //     if (std.mem.eql(u8, value, "*")) {
    //         var result: u64 = 1;
    //         for (numbers.items[i].items) |line| {
    //             std.debug.print("i={}: result:{}*= line:{}\n", .{ i, result, line });
    //             result *= line;
    //         }
    //         std.debug.print("Adding {} to final result: {}\n", .{ result, final_result });
    //         final_result += result;
    //     } else if (std.mem.eql(u8, value, "+")) {
    //         var result: u64 = 0;
    //         for (numbers.items[i].items) |line| {
    //             std.debug.print("i={}:result:{}+= line:{}\n", .{ i, result, line });
    //             result += line;
    //         }
    //         std.debug.print("Adding {} to final result: {}\n", .{ result, final_result });
    //         final_result += result;
    //     } else {
    //         // const s: u64 = try std.fmt.parseInt(u64, value, 10);
    //     }
    //     i += 1;
    // }
    //

    std.debug.print("result: {}\n", .{final_result});
    try day6.bufferedPrint();
}
