const std = @import("std");

const linux = std.os.linux;
const print = std.debug.print;

pub fn main() !void {
    const pid = linux.fork();
    if (pid == 0) {
        // we are the child
        const mypid = linux.getpid();
        print("child: I am printed by child...pid={}\n", .{mypid});
        // sleep 1 second
        std.Thread.sleep(2_000_000_000);
        print("child: I am exiting...pid={}\n", .{mypid});
        std.process.exit(0);
    }
    var status: u32 = undefined;
    const rc = linux.waitpid(@intCast(pid), &status, 0);
    print("parent: I am printed by parent...status={}, rc={}\n", .{ status, rc });
    std.process.exit(0);
}
