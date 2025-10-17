const std = @import("std");

pub fn main() !u8 {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    try stdout.print("zig shell", .{});
    try shellLoop(stdin, stdout);

    return 0;
}

// https://www.reddit.com/r/Zig/comments/1d0cm1k/very_confused_with_ptrcast_from_const_u8_to/
fn shellLoop(stdin: std.fs.File.Reader, stdout: std.fs.File.Writer) !void {
    while (true) {
        const max_input = 1024;
        const max_args = 10;

        try stdout.print("=> ", .{});

        var input_buffer: [max_input]u8 = undefined;
        const input_str = (try stdin.readUnitDelimiterOrEof(input_buffer[0..], '\n')) orelse {
            try stdout.print("\n", .{});
            return;
        };

        if (input_str.len == 0) continue;

        var args_parts: [max_args:null]?[*:0]u8 = undefined;

        var i: usize = 0;
        var n: usize = 0;
        var ofs: usize = 0;

        while (i <= input_str.len) : (i += 1) {
            if (input_buffer[i] == 0x20 or input_buffer[i] == 0xa) {
                input_buffer[i] = 0;
                args_parts[n] = @ptrCast(&input_buffer[ofs..i :0]);
                n += 1;
                ofs = i + 1;
            }
        }
        args_parts[n] = null;
        const fork_pid = try std.os.fork();

        if (fork_pid == 0) {
            // child
            const env = [_:null]?[*:0]u8{null};
            const result = std.os.execvpeZ(args_parts[0].?, &args_parts, &env);
            try stdout.print("error: {}", .{result});
        } else {
            const wait_result = std.os.waitpid(fork_pid, 0);
            if (wait_result.status != 0) {
                try stdout.print("return {}\n", .{wait_result.status});
            }
        }
    }
}
