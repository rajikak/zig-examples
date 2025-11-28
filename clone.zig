const std = @import("std");
const linux = std.os.linux;

fn child(arg: usize) callconv(.c) u8 {
    std.debug.print("child: pid: '{d}', arg: {d}\n", .{ linux.getpid(), arg });
    return 0;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const stack_size = 1024 * 1024;
    const stack = try allocator.alloc(u8, stack_size);

    const flags: u32 = linux.CLONE.VM;

    const stack_ptr = @intFromPtr(stack.ptr + stack_size);
    const child_pid = linux.clone(
        &child,
        stack_ptr,
        flags,
        0,
        null,
        0,
        null,
    );

    var status: u32 = undefined;
    const waitpid_flags: u32 = 0;
    const rc = linux.waitpid(@intCast(child_pid), &status, waitpid_flags);

    std.debug.print("parent: child exited with status: '{d}', pid: '{d}', wait_pid: '{d}'\n", .{
        child_pid,
        linux.getpid(),
        rc,
    });
}
