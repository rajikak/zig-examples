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
    log.info("Args {{ debug: {}, command: {s}, uid: {d}, mount_dir: {s} }}", .{ args.debug, args.command, args.uid, args.mount_dir });

    try start(args);
    try exitWithRetCode(null);
}

fn start(args: Args) !void {
    const container = try Container.new(args);
    container.create() catch |err| {
        log.err("Error while creating the container: {any}", .{err});
        return error.ContainerCreationError;
    };
    log.debug("Finished, cleaning & exit", .{});
    try container.cleanExit();
}

const Container = struct {
    config: ContainerOpts,

    fn new(args: Args) !Container {
        const config = try ContainerOpts.new(args.command, args.uid, args.mount_dir);
        return Container{
            .config = config,
        };
    }

    pub fn create(self: Container) !void {
        _ = self;
        log.debug("Creation finsihed", .{});
    }

    pub fn cleanExit(self: Container) !void {
        _ = self;
        log.debug("Cleaning container", .{});
    }
};

const ContainerOpts = struct {
    path: []const u8,
    argv: std.ArrayList([]const u8),
    uid: u32,
    mount_dir: []const u8,

    fn new(command: []const u8, uid: u32, mount_dir: []const u8) !ContainerOpts {
        const buf_size = 1000;
        var buffer: [buf_size]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&buffer);
        defer fba.reset();
        const allocator = fba.allocator();

        var list: std.ArrayList([]const u8) = .empty;
        var it = std.mem.splitSequence(u8, command, " ");
        while (it.next()) |v| {
            try list.append(allocator, v);
        }

        return ContainerOpts{ .path = list.items[0], .argv = list, .uid = uid, .mount_dir = mount_dir };
    }

    fn print(self: ContainerOpts) void {
        log.info("ContainerOpts {{ path: {s}, uid: {d}, mount_dir: {s} }}\n", .{ self.path, self.uid, self.mount_dir });
    }
};

// https://www.chromium.org/chromium-os/developer-library/reference/linux-constants/errnos/
const ErrCode = union(enum) {
    // https://ziglang.org/documentation/0.15.2/std/#std.os.linux.E
    OsError: std.os.linux.E,
    ArgumentInvalid,

    fn errCode(val: ErrCode) u8 {
        switch (val) {
            .ArgumentInvalid => return 1,
            .OsError => return @intFromEnum(val),
        }
    }
};
const Args = struct {
    debug: bool,
    command: []const u8,
    uid: u32,
    mount_dir: []const u8,
};

fn exitWithRetCode(errorCode: ?ErrCode) !void {
    if (errorCode) |v| {
        const code = ErrCode.errCode(v);
        log.debug("Error on exit: {}, code: {}\n", .{ v, code });
        std.posix.exit(code);
    } else {
        log.debug("Exit without any error, returning 0\n", .{});
        std.posix.exit(0);
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
            const uid = try std.fmt.parseInt(u32, val, 10);
            arg.uid = uid;
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
