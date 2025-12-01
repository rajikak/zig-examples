const std = @import("std");
const linux = std.os.linux;
const posix = std.posix;
const c = @cImport({
    @cInclude("unistd.h");
    @cDefine("_GNU_SOURCE", {});
    @cInclude("sched.h");
});

fn child_fn(arg: usize) callconv(.c) u8 {
    _ = arg;
    const new_name = "anvilci.org.ip-172-31-28-233.ec2.internal";

    // Show uname() data
    const uts: posix.utsname = posix.uname();
    //std.debug.print("[child]in new UTS namespace: nodename={s}\n", .{uts.nodename});

    const rc = c.sethostname(new_name, new_name.len);
    if (rc != 0) {
        const err = std.posix.errno(rc);
        std.debug.print("[child] sethostname failed, error={any}\n", .{err});
        return 1;
    }
    std.debug.print("[child]in new UTS namespace: nodename={s}\n", .{uts.nodename});

    return 0; // exit status of the child
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    // Allocate a stack for the child; stack grows downward, so pass top address.
    const stack_size: usize = 1 << 20; // 1 MiB
    var stack_mem = try allocator.alloc(u8, stack_size);
    defer allocator.free(stack_mem);
    const stack_top = @intFromPtr(&stack_mem[stack_mem.len - 1]);

    // Flags: NEWUTS plus a termination signal in low byte (SIGCHLD)
    const flags: u32 = linux.CLONE.NEWUTS | @as(u32, posix.SIG.CHLD);

    // ptid/ctid/tp are optional for this simple case
    const pid = linux.clone(
        child_fn,
        stack_top,
        flags,
        0, // arg to child_fn
        null, // ptid
        0, // tp (TLS) — not used here
        null, // ctid
    );

    if (pid == -1) {
        const err = posix.errno(pid);
        return std.debug.print("[parent]clone failed: errno={}\n", .{err});
    }

    // Parent waits for SIGCHLD / child exit
    const waited = posix.waitpid(@intCast(pid), 0);
    if (waited.status < 0) {
        const err = posix.errno(waited.status);
        return std.debug.print("[parent]waitpid failed: errno={}\n", .{err});
    }

    // Show parent’s hostname (unchanged)
    const uts: posix.utsname = posix.uname();
    std.debug.print("[parent] hostname unaffected: nodename={s}\n", .{uts.nodename});
}
