const std = @import("std");
const linux = std.os.linux;

const buf_size = 100;

fn log(s: []const u8) !void {
    var buf: [buf_size]u8 = undefined;
    var w = std.fs.File.stdout().writer(&buf);
    const stdout = &w.interface;

    stdout.print(s);
    stdout.flush();
}

pub fn main() !void {
    
    
    var buf:[buf_size]u8 = undefined;
    const a = try std.fmt.bufPrint(&buf, "[parent]: pid = {d}\n", .{linux.getpid()});

    log()

}
