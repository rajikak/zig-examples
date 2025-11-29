const std = @import("std");
const linux = std.os.linux;

const Arg = struct {
    n: u8,
    buf: []const u8,

    fn init(n: u8, buf: []const u8) Arg {
        return Arg{ .n = n, .buf = buf };
    }
};

fn child(arg: usize) callconv(.c) u8 {
    const input: *Arg = @ptrFromInt(arg);
    const tid = linux.gettid();
    const pid = linux.getpid();
    const ppid = linux.getppid();

    std.debug.print("child:  tid: {}, pid: {}, ppid: {}, n = {d}, args = {s}\n", .{ tid, pid, ppid, input.n, input.buf });

    return 0;
}

pub fn main() !void {
    var fd: [2]i32 = undefined;
    const pres = std.os.linux.pipe(&fd);

    if (pres == -1) {
        std.debug.print("error: pipe\n", .{});
        return error.SyscallError;
    }

    std.debug.print("pipe {d}, reader_fd: {d}, writer_fd:{d}\n", .{ pres, fd[0], fd[1] });

    const stack_size: usize = 8 * 1024;
    const stack_memory = try std.heap.page_allocator.alloc(u8, stack_size);
    defer std.heap.page_allocator.free(stack_memory);

    const stack_ptr = @intFromPtr(stack_memory.ptr + stack_size);
    const clone_flags = linux.CLONE.VM | linux.SIG.CHLD;

    const arg = Arg.init(4, "go build -o main");
    const pid = linux.clone(
        child,
        stack_ptr,
        clone_flags,
        @intFromPtr(&arg),
        null,
        0,
        null,
    );
    var status: u32 = undefined;
    const wait_flags = 0;

    const pipe = fd[1];
    const wres = linux.write(pipe, "ok", 2);
    if (wres == -1) {
        std.debug.print("error: write\n", .{});
        return error.SyscallError;
    }

    const cres = linux.close(pipe);
    if (cres == -1) {
        std.debug.print("error: close\n", .{});
        return error.SyscallError;
    }

    _ = linux.waitpid(@intCast(pid), &status, wait_flags);
    std.debug.print("parent: tid: {}, pid: {}, ppid: {}\n", .{ linux.gettid(), linux.getpid(), linux.getppid() });
}
