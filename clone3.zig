const std = @import("std");
const linux = std.os.linux;

fn child(arg: usize) callconv(.c) u8 {
    _ = arg;
    const tid = linux.gettid();
    const pid = linux.getpid();
    const ppid = linux.getppid();

    std.debug.print("child: work sarted\n", .{});
    std.Thread.sleep(4_000_000);
    std.debug.print("child:  tid: {d}, pid: {d}, ppid:{d}\n", .{ tid, pid, ppid });
    std.debug.print("child: finished child\n", .{});
    return 0;
}
pub fn main() !void {
    const stack_size: usize = 8 * 1024;
    const stack_memory = try std.heap.page_allocator.alloc(u8, stack_size);
    defer std.heap.page_allocator.free(stack_memory);

    const stack_ptr = @intFromPtr(stack_memory.ptr + stack_size);
    const clone_flags = linux.CLONE.VM | linux.SIG.CHLD | linux.CLONE.FILES;
    //const clone_flags = linux.CLONE.VM | linux.CLONE.THREAD | linux.CLONE.SIGHAND | linux.CLONE.FILES | linux.CLONE.FS | linux.SIG.CHLD;

    std.debug.print("parent process starting clone...\n", .{});

    const pid_or_err = linux.clone(
        child,
        stack_ptr,
        clone_flags,
        0,
        null,
        0,
        null,
    );
    std.debug.print("clone returned, child pid: {}\n", .{pid_or_err});
    std.Thread.sleep(1_000_000);

    var status: u32 = undefined;
    const wpid: linux.pid_t = @intCast(pid_or_err);
    const wflags = std.c.W.UNTRACED | std.c.W.CONTINUED;

    // https://man7.org/linux/man-pages/man2/wait.2.html
    const res = linux.waitpid(wpid, &status, wflags);

    std.debug.print("parent: tid: {d}, pid: {d}, child exited result(clone): {d}, status: {d}, result(waitpid): {}\n", .{ linux.gettid(), linux.getpid(), wpid, status, res });
}
