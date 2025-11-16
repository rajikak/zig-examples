const std = @import("std");

pub fn main() !void {
    try exec();
    std.debug.print("function as an argument!\n", .{});
}

fn exec() !void {
    const pid = std.os.linux.getpid();
    std.debug.print("exec: pid = {}\n", .{pid});
}
