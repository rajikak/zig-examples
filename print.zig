const std = @import("std");

pub fn main() void {
    std.debug.print("binary: {b}\n", .{32});
    std.debug.print("octal: {o}\n", .{32});
    std.debug.print("hex(lower): {x}\n", .{255});
    std.debug.print("hex(lower): 0x{x}\n", .{255});
    std.debug.print("hex(upper): {X}\n", .{255});
    std.debug.print("charcter: {c}\n", .{'a'});

    std.debug.print("IEEE: {e}\n", .{12345.6789});

    std.debug.print("right alignment: {s:->10}\n", .{"zig lang"});
    std.debug.print("center alignment: {s:_^10}\n", .{"zig lang"});
    std.debug.print("left alignment: {s:_<10}\n", .{"zig lang"});
    std.debug.print("left alignment(no padding): {s:<10}\n", .{"zig lang"});
}
