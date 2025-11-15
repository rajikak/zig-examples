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

    const v1: u8 = 26;
    std.debug.print("0x{x}\n", .{v1}); // "0x1a"
    std.debug.print("0x{X}\n", .{v1}); // "0x1A"

    const v2: u16 = 43;
    std.debug.print("0x{x}\n", .{v2}); //     "0x1"
    std.debug.print("0x{x:2}\n", .{v2}); //   "0x 1"
    std.debug.print("0x{x:4}\n", .{v2}); //   "0x   1"
    std.debug.print("0x{x:0>4}\n", .{v2}); // "0x0001"

    const v3: u16 = 43;
    std.debug.print("0x{x:0>4}\n", .{v3}); // "0x002b"
    std.debug.print("0x{X:0>8}\n", .{v3}); // "0x0000002B"

    const v4: u32 = 0x1a2b3c;
    std.debug.print("0x{X:0>2}\n", .{v4}); // "0x1A2B3C" (not cut off)
    std.debug.print("0x{x:0>8}\n", .{v4}); // "0x001a2b3c"

}
