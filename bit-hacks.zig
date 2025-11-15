const std = @import("std");

pub fn main() void {
    const uts = std.os.linux.CLONE.NEWUTS;
    const sigchild = 0x11;

    const flags = sigchild | uts;
    std.debug.print("sigchild: {}, 0x{x}, bx{b},{}\n", .{ sigchild, sigchild, @TypeOf(sigchild) });
    std.debug.print("uts: {}, x{x}, bx{b}, {}\n", .{ uts, uts, @TypeOf(uts) });
    std.debug.print("flags: {}, 0x{x}, {}\n", .{ flags, flags, @TypeOf(flags) });
}
