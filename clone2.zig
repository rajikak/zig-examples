const std = @import("std");
const linux = std.os.linux;

fn child(arg: usize) callconv(.c) u8 {
    _ = arg;
    const tid = linux.gettid();
    const pid = linux.getpid();

    std.Thread.sleep(1_000_000);
    std.debug.print("child: tid: {d}, pid: {}\n", .{ tid, pid });
    return 0;
}
pub fn main() !void {
    const stack_size: usize = 8 * 1024;
    const stack_memory = try std.heap.page_allocator.alloc(u8, stack_size);
    defer std.heap.page_allocator.free(stack_memory);

    const stack_ptr = @intFromPtr(stack_memory.ptr + stack_size);
    const clone_flags = linux.CLONE.VM | linux.CLONE.THREAD | linux.CLONE.SIGHAND | linux.CLONE.FILES | linux.CLONE.FS;

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
    std.Thread.sleep(2_000_000);

    // wiat for the child process to exit
    var status: u32 = undefined;
    const rc = linux.waitpid(@intCast(pid_or_err), &status, 0);
    std.debug.print("parent: child exited result: {}, status: {}\n", .{ rc, status });
}
