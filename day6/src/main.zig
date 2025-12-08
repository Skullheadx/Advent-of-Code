const std = @import("std");
const day6 = @import("day6");

pub fn main() !void {
    // Initiate allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    // Read contents from file "./filename"
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(alloc, "day6.txt", 24000);
    defer alloc.free(fileContents);

    var numbers = std.array_list.Aligned(std.array_list.Aligned(u64, null), null).empty;
    defer {
        for (numbers.items) |*row| {
            row.deinit(alloc);
        }
        numbers.deinit(alloc);
    }
    // Print file contents
    // std.debug.print("{s}", .{fileContents});
    var lines = std.mem.splitScalar(u8, fileContents, '\n');

    var final_result: u64 = 0;

    var isFirstRun: bool = true;
    while (lines.next()) |row| {
        if (row.len == 0) { // break between ranges and values
            break;
        }
        var r = std.mem.splitScalar(u8, row, ' ');
        var i: usize = 0;
        while (r.next()) |value| {
            if (value.len == 0) {
                continue;
            }
            if (isFirstRun) {
                try numbers.append(alloc, std.array_list.Aligned(u64, null).empty);
            }
            if (std.mem.eql(u8, value, "*")) {
                var result: u64 = 1;
                for (numbers.items[i].items) |line| {
                    std.debug.print("i={}: result:{}*= line:{}\n", .{ i, result, line });
                    result *= line;
                }
                std.debug.print("Adding {} to final result: {}\n", .{ result, final_result });
                final_result += result;
            } else if (std.mem.eql(u8, value, "+")) {
                var result: u64 = 0;
                for (numbers.items[i].items) |line| {
                    std.debug.print("i={}:result:{}+= line:{}\n", .{ i, result, line });
                    result += line;
                }
                std.debug.print("Adding {} to final result: {}\n", .{ result, final_result });
                final_result += result;
            } else {
                const s: u64 = try std.fmt.parseInt(u64, value, 10);
                try numbers.items[i].append(alloc, s);
            }
            i += 1;
        }
        isFirstRun = false;
    }

    std.debug.print("result: {}\n", .{final_result});
    try day6.bufferedPrint();
}
