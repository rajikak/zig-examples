const std = @import("std");

const Syscalls = struct {
    pub fn getpid() i32 {
        return std.os.linux.getpid();
    }

    pub fn getpid2() usize {
        return std.os.linux.syscall0(.getpid);
    }

    pub fn pipe() [2]i32 {
        return std.os.linux.syscall0(.pipe);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var args = try parseArgs(alloc);
    defer args.deinit(alloc);

    for (args.items) |item| {
        std.debug.print("{s}\n", .{item});
    }
}

const Arg = struct {
    debug: bool,
    command: []const u8,
    uid: u32,
    mout_dir: std.fs.path,
};

fn parseArgs(allocator: std.mem.Allocator) !std.ArrayList([]const u8) {
    var list: std.ArrayList([]const u8) = .empty;

    var args = std.process.args();
    _ = args.skip(); // skip the program name

    while (args.next()) |arg| {
        try list.append(allocator, arg);
    }
    return list;
}
