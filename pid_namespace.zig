const std = @import("std");
const linux = std.os.linux;
const posix = std.posix;
const c = @cImport({
    @cInclude("unistd.h");
    @cDefine("_GNU_SOURCE", {});
    @cInclude("sched.h");
});

// see mkdir.c
fn child_fn3(arg: usize) callconv(.c) u8 {
    _ = arg;

    const mount_point = "/tmp/pidns.2";
    const mode = 0o555;
    std.posix.mkdir(mount_point, mode) catch |err| {
        std.debug.print("[child] error: mkdir error: {}\n", .{err});
    };

    const fstype = "proc"; // see cat /proc/filesystems
    const source = "proc";
    const res = std.os.linux.syscall5(.mount, @intFromPtr(source.ptr), @intFromPtr(mount_point.ptr), @intFromPtr(fstype.ptr), 0, 0);
    const e = std.os.linux.E.init(res);
    if (e != .SUCCESS) {
        std.debug.print("[child] error using mount: {}\n", .{e});
    }

    std.debug.print("[child] child_fn3 completed\n", .{});

    return 0;
}

// using Zig system call
fn child_fn2(arg: usize) callconv(.c) u8 {
    _ = arg;

    const uts1 = posix.uname();
    std.debug.print("[child] in new UTS namespace: nodename={s}\n", .{uts1.nodename});

    const hostname = "anvilci2.org.ip-172-31-28-233.ec2.internal";
    const res = std.os.linux.syscall2(.sethostname, @intFromPtr(hostname.ptr), hostname.len);
    const e = std.os.linux.E.init(res);
    if (e != .SUCCESS) {
        std.debug.print("[child] error setting hostname: {}\n", .{e});
        return 0;
    }

    const uts2 = posix.uname();
    std.debug.print("[child] in new UTS namespace: nodename={s}\n", .{uts2.nodename});

    return 0;
}

// using native systems calls
fn child_fn(arg: usize) callconv(.c) u8 {
    _ = arg;
    const new_name = "anvilci.org.ip-172-31-28-233.ec2.internal";

    // Show uname() data
    const uts1: posix.utsname = posix.uname();
    std.debug.print("[child]in new UTS namespace: nodename={s}\n", .{uts1.nodename});

    const rc = c.sethostname(new_name, new_name.len);
    if (rc != 0) {
        const err = std.posix.errno(rc);
        std.debug.print("[child] sethostname failed, error={any}\n", .{err});
        return 1;
    }
    const uts2 = posix.uname();
    std.debug.print("[child]in new UTS namespace: nodename={s}\n", .{uts2.nodename});

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
        child_fn3,
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
