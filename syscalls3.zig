const std = @import("std");
const linux = std.os.linux;
const posix = std.posix;

fn child(arg: usize) callconv(.c) u8 {
    _ = arg;
    std.debug.print("hello from child\n", .{});
    return 0;
}

const Args = struct { name: []const u8, value: []const u8 };

pub fn main() !void {
    //const allocator = std.heap.page_allocator;

    // Allocate a stack for the child thread
    //const stack_size = 1024 * 1024; // 1 MB
    //const stack_mem = try allocator.alloc(u8, stack_size);
    const stack: [4096]u8 = undefined;

    const flags: u32 = linux.CLONE.VM;
    // const flags: u32 = linux.SIG.CHLD | linux.CLONE.NEWUTS;
    // const flags: u32 = linux.CLONE.VM | linux.CLONE.FS | linux.CLONE.FILES | linux.CLONE.SIGHAND | linux.CLONE.THREAD;

    const val = Args{ .name = "name value", .value = "arg value" };

    // Call clone
    const child_pid = linux.clone(
        &child,
        //@intFromPtr(stack_mem.ptr + stack_size), // stack grows downward
        @intFromPtr(&stack),
        flags,
        @intFromPtr(&val), // argument to child
        null,
        0,
        null,
    );

    if (child_pid == 0) {
        // We're in the child (but usually child returns immediately)
        return;
    }

    //var status: u32 = undefined;
    //const waitpid_flags = linux.W.UNTRACED | linux.W.CONTINUED;
    const pid2: linux.pid_t = @intCast(child_pid);
    //const res = std.os.linux.waitpid(pid2, &status, waitpid_flags);
    //const res = std.os.linux.waitpid(pid2, &status, 0);
    //if (res < 0) {
    //    std.debug.print("wait pid error: {}\n", .{res});
    //}
    //const res1 = posix.waitpid(pid2, waitpid_flags);
    //std.debug.print("posix.waitpid = {}\n", .{res1.pid});

    std.debug.print("Parent: PID = {d}, child PID = {d}, {d}\n", .{ std.os.linux.getpid(), child_pid, pid2 });
}
