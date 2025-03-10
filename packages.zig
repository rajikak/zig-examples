const std = @import("std");
const time = std.time;
const posix = std.posix;

pub fn main() void {
    std.debug.print("the time now is {}\n", .{time.milliTimestamp()});
}
