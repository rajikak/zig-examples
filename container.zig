const std = @import("std");
const log = std.log;

pub const log_level: std.log.Level = .debug;

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
    const args = try parseArgs();
    log.info("Args {{ debug: {}, command: {s}, uid: {s}, mount_dir: {s} }}\n", .{ args.debug, args.command, args.uid, args.mount_dir });
}

const Container = struct {
    config: ContainerOpts,

    fn new(args: Args) Container {
        const config = ContainerOpts.new(args.command, args.uid, args.mout_dir);
        return Container {.config = config};
    }
};

const ContainerOpts = struct {
    path: []const u8,
    argv: std.ArrayList([]const u8),
    uid: u32,
    mount_dir: []const u8,

    fn new(command: []const u8, uid: u32, mount_dir: []const u8) ContainerOpts {
        const buf_size = 1000;
        var buffer: [buf_size]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&buffer);
        defer fba.reset();
        const allocator = fba.allocator();

        var list: std.ArrayList([]const u8) = .empty;
        var it = std.mem.split(u8, command, " ");
        while (it.next()) |v| {
            try list.append(allocator, v);
        }

        return ContainerOpts{ .path = list.items[0], .argv = list, .uid = uid, .mount_dir = mount_dir };
    }

    fn print(self: ContainerOpts) void {
        log.info("ContainerOpts {{ path: {s}, uid: {d}, mount_dir: {s} }}\n", .{ self.path, self.uid, self.mount_dir });
    }
};

// https://tldp.org/LDP/abs/html/exitcodes.html
const ErrCode = enum {
    ArgumentInvalid,

    fn errCode(val: ErrCode) u8 {
        switch (val) {
            .ArgumentInvalid => 1,
            else => -1,
        }
    }
};
const Arg = struct {
    debug: bool,
    command: []const u8,
    uid: []const u8,
    mount_dir: []const u8,
};

fn exitWithRetCode(err: ?ErrCode) !void {
    if (err) |v| {
        const code = ErrCode.errCode(v);
        log.debug("error on exit: {}, code: {}\n", .{ v, code });
        std.os.exit(code);
    } else {
        log.debug("exit without any error, returning 0\n", .{});
        std.os.exit(0);
    }
}

fn parseArgs() !Args {
    var args = std.process.args();
    _ = args.skip(); // skip the program name

    var arg: Args = undefined;
    arg.debug = false;

    while (args.next()) |v| {
        var splits = std.mem.splitSequence(u8, v, "=");
        const key = splits.first();
        const val = splits.next().?;
        if (std.mem.eql(u8, key, "mount")) {
            arg.mount_dir = val;
        } else if (std.mem.eql(u8, key, "uid")) {
            arg.uid = val;
        } else if (std.mem.eql(u8, key, "debug") and std.mem.eql(u8, val, "true")) {
            arg.debug = true;
        } else if (std.mem.eql(u8, key, "command")) {
            arg.command = val;
        } else {
            log.err("{s}: {s}\n", .{ key, val });
            return error.UnknownArgument;
        }
    }

    return arg;
}
