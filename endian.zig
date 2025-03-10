const std = @import("std");
const ending = @import("bultin").cpu.arch.endian();

pub fn main() !void {
    var buf: [4]u8 = undefined;
    std.mem.writeInt(u32, &buf, 257, .big);
    std.debug.print("big-endian: {any}\n", .{&buf});

    std.mem.writeInt(u32, &buf, 257, .little);
    std.debug.print("little-endian: {any}\n", .{&buf});
}
