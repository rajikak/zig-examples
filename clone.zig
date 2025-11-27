const std = @import("std");
const linux = std.os.linux;
const posix = std.posix;

fn child(arg: usize) callconv(.c) u8 {
    std.debug.print("child: pid: '{d}', arg: {d}\n", .{ linux.getpid(), arg });
    return 0;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const stack_size = 1024 * 1024;
    const stack = try allocator.alloc(u8, stack_size);

    const flags: u32 = linux.CLONE.VM;

    const child_pid = linux.clone(
        &child,
        @intFromPtr(stack.ptr + stack_size),
        flags,
        32,
        null,
        0,
        null,
    );

    if (child_pid == -1) {
        std.debug.print("clone failed, error: {d}\n", .{child_pid});
        return -1;
    }

    var status: u32 = 0;
    const waitpid_flags: u32 = 0;
    const wait_pid_input: linux.pid_t = @intCast(child_pid);
    const wait_pid = linux.waitpid(wait_pid_input, &status, waitpid_flags);

    std.debug.print("parent: child exited with status: '{d}', pid: '{d}', wait_pid: '{d}'\n", .{
        child_pid,
        linux.getpid(),
        wait_pid,
    });
}
