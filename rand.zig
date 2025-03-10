const std = @import("std");
const rand = std.crypto.random;

pub fn main() void {
    std.debug.print("my favorite float is {any}\n", .{rand.float(f32)});
    std.debug.print("my favorite boolean is {any}\n", .{rand.boolean()});
    std.debug.print("my favorite int is {d}\n", .{rand.int(u8)});
    std.debug.print("my favorite int > 0 and < 255 is {d}\n", .{rand.intRangeAtMost(u8, 0, 255)});
}
