const std = @import("std");

fn err(comptime format: []const u8, args: anytype) noreturn {
    std.debug.print(format, args);
    std.process.exit(1);
}

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_state.deinit();
    const allocator = arena_state.allocator();

    const args = try std.process.argsAlloc(allocator);
    var opt_input_file_path: ?[]const u8 = null;

    {
        var i: usize = 1;
        while (i < args.len) : (i += 1) {
            const arg = args[i];
            if (std.mem.eql(u8, "--input-file", arg)) {
                i += 1;
                if (i > args.len) err("expected arg after '{s}'", .{arg});
                if (opt_input_file_path != null) err("duplicated arg '{s}'", .{arg});
                opt_input_file_path = args[i];
            } else {
                err("unrecognized arg '{s}'", .{arg});
            }
        }
    }

    const input_file_path = opt_input_file_path orelse err("missing --input-file", .{});
    var input_file = std.fs.cwd().openFile(input_file_path, .{}) catch |er| {
        err("unable to open file '{s}: {s}", .{ input_file_path, @errorName(er) });
    };
    defer input_file.close();

    var buf_reader = std.io.bufferedReader(input_file.reader());
    const reader = buf_reader.reader();

    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();

    const writer = line.writer();
    var line_no: usize = 0;
    while (reader.streamUntilDelimiter(writer, '\n', null)) {
        defer line.clearRetainingCapacity();
        line_no += 1;
        std.debug.print("{d}: | {s}\n", .{ line_no, line.items });
    } else |er| switch (er) {
        error.EndOfStream => { // end of file
            if (line.items.len > 0) {
                line_no += 1;
                std.debug.print("{d}: | {s}\n", .{ line_no, line.items });
            }
        },
        else => return er, // Propagate error
    }

    std.debug.print("Total lines: {d}\n", .{line_no});
    return std.process.cleanExit();
}
