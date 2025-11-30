const std = @import("std");
const linux = std.os.linux;

const c = @cImport({
    @cInclude("unistd.h");
    @cInclude("stdlib.h");
});

const Arg = struct {
    buf: []const u8,

    fn init(buf: []const u8) Arg {
        return Arg{ .buf = buf };
    }
};

fn child(arg: usize) callconv(.c) u8 {
    const input: *Arg = @ptrFromInt(arg);

    std.debug.print("[child]  tid={d}, pid={d}, ppid={d}, buf={s}\n", .{ linux.gettid(), linux.getpid(), linux.getppid(), input.buf });

    return 0;
}

pub fn toPid(x: usize) !linux.pid_t {
    if (x > std.math.maxInt(u64)) return error.PidOutOfRange;
    return @intCast(x);
}

pub fn main() !void {
    //const stack_size: usize = 1024 * 1024;
    //const stack_memory = try std.heap.page_allocator.alloc(u8, stack_size);
    //defer std.heap.page_allocator.free(stack_memory);

    //const stack_ptr = @intFromPtr(stack_memory.ptr + stack_size);
    //const clone_flags = linux.CLONE.NEWUTS | linux.SIG.CHLD | linux.CLONE.VM;

    //const arg = Arg.init("nshostname.org"); // set a sample hostname

    var buffer: [std.posix.HOST_NAME_MAX]u8 = undefined;
    const res = try std.posix.gethostname(&buffer);
    const uts = std.posix.uname();
    std.debug.print("hostname={s}, uts={s}\n", .{ res, uts.nodename });

    const host = "anvilci.com";
    const rc = c.sethostname(host, host.len);
    if (rc != 0) {
        const err = std.posix.errno(rc);
        std.debug.print("[error]sethostname failed, error={}, {any}\n", .{ err, rc });
        return;
    }
    std.debug.print("hostname={s}, uts={s}\n", .{ res, uts.nodename });

    //std.debug.print("[parent] tid={d}, pid={d}, ppid={d}, clone={d}\n", .{ linux.gettid(), linux.getpid(), linux.getppid(), pid });

}
