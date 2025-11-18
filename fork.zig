const std = @import("std");
const os = std.os;

pub fn main() !void {
    const pid = os.linux.fork();
    if (pid == 0) {
        // Child process
        std.debug.print("Child process running...\n", .{});
        std.debug.print("Child is done!\n", .{});
        return;
    } else {
        // Parent process
        var status: u32 = 0;
        const pid2: os.linux.pid_t = @intCast(pid);
        const result = os.linux.waitpid(pid2, &status, 0);
        if (result < 0) {
            return os.unexpectedErrno(os.errno(result));
        }
        std.debug.print("Child exited with status: {d}\n", .{status});
    }
}
