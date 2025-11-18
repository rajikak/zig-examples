const std = @import("std");
const linux = std.os.linux;

pub fn main() !void {
    std.debug.print("function as an argument!\n", .{});
    try clone1();
}

fn clone2() !void {
    const stack: [4096]u8 = undefined;
    const stack_top = stack[stack.len - 1];
    const flags: u32 = linux.SIG.CHLD | linux.CLONE.NEWUTS;
    const tls: u32 = 0;

    // missing syscall8
    const res = std.os.linux.syscall7(.clone3, &child, stack_top, flags, 1234, null, tls, null);
    if (res < 0) {
        return error.Unpexpcted;
    }
}

fn clone1() !void {
    var stack: [4096]u8 = undefined;
    const ptrcast: *u8 = @constCast(&stack);
    const stack_top = ptrcast + stack.len;
    const flags: u32 = linux.SIG.CHLD | linux.CLONE.NEWUTS;
    const tls: usize = 1;

    const ftype = *const fn (arg: usize) callconv(.c) u8;
    const chfun: ftype = @ptrCast(&child);

    const pid = linux.clone(chfun, stack_top, flags, 1234, null, tls, null);
    if (pid < 0) {
        return error.Unpexpcted;
    }
}

fn child(arg: usize) callconv(.c) u8 {
    std.debug.print("child process: pid: {}, arg={}\n", .{ std.os.linux.getpid(), arg });
    return 0;
}

fn getPid() !void {
    const pid = std.os.linux.getpid();
    std.debug.print("exec: pid = {}\n", .{pid});
}
