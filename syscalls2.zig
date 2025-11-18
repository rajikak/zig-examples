const std = @import("std");
const linux = std.os.linux;

fn child(arg: usize) callconv(.c) u8 {
    std.debug.print("Child running with arg: {}\n", .{arg});
    return 0; // Exit code
}

pub fn main() !void {
    std.debug.print("function as an argument!\n", .{});
    try clone1();
}

fn clone1() !void {
    // Allocate stack

    const flags: u32 = linux.SIG.CHLD | linux.CLONE.NEWUTS;
    //const tls: usize = 0;

    const pid = linux.clone(&child, 4096, flags, 1234, null, 2, null);
    if (pid < 0) {
        return error.Unexpected;
    }

    std.debug.print("Clone returned pid: {}\n", .{pid});
}
