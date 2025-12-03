const std = @import("std");
const linux = std.os.linux;

const c = @cImport({
    @cInclude("string.h");
    @cInclude("unistd.h");
    @cDefine("_GNU_SOURCE", {});
    @cInclude("sched.h");
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

    var buffer: [std.posix.HOST_NAME_MAX]u8 = undefined;
    const res = std.posix.gethostname(&buffer) catch |err| {
        std.debug.print("error: {}", err);
    };
    const uts = std.posix.uname();
    std.debug.print("hostname={s}, uts={s}\n", .{ res, uts.nodename });

    const host = "anvilci.com";
    const rc = c.sethostname(host, host.len);
    if (rc != 0) {
        const err = std.posix.errno(rc);
        std.debug.print("[error]sethostname failed, error={}\n", .{err});
    }

    return 0;
}

fn child2(arg: ?*anyopaque) callconv(.c) c_int {
    _ = arg;
    //std.debug.print("[child]  tid={d}, pid={d}, ppid={d}, buf={s}\n", .{ linux.gettid(), linux.getpid(), linux.getppid(), input.buf });
    std.debug.print("[child]  tid={d}, pid={d}, ppid={d}\n", .{ linux.gettid(), linux.getpid(), linux.getppid() });

    return 0;
}

pub fn toPid(x: usize) !linux.pid_t {
    if (x > std.math.maxInt(u64)) return error.PidOutOfRange;
    return @intCast(x);
}

pub fn main() !void {
    const stack_size: usize = 1024 * 1024;
    const stack_memory = try std.heap.page_allocator.alloc(u8, stack_size);
    defer std.heap.page_allocator.free(stack_memory);

    const stack_ptr = @intFromPtr(stack_memory.ptr + stack_size);
    const clone_flags = linux.CLONE.NEWUTS | linux.SIG.CHLD | linux.CLONE.VM;

    const pid = c.clone(child2, @ptrFromInt(stack_ptr), clone_flags, null);
    if (pid == -1) {
        std.debug.print("[parent] clone error{}, {s}\n", .{ std.posix.errno(pid), c.strerror(pid) });
        return error.SyscallError;
    }
    std.debug.print("[parent] tid={d}, pid={d}, ppid={d}, clone={d}\n", .{ linux.gettid(), linux.getpid(), linux.getppid(), pid });

    const wait_flags = 0;
    var status: u32 = undefined;
    const res = linux.waitpid(@intCast(pid), &status, wait_flags);
    if (res == -1) {
        std.debug.print("error: waitpid\n", .{});
        return error.SyscallError;
    }
}
