// nc  localhost 8443

const std = @import("std");
const net = std.net;
const posix = std.posix;
const print = std.debug.print;

pub fn main() !void {
    const server = DnsServer.init("127.0.0.1", 8443);
    try server.start();
    print("dns server is ready\n", .{});
}

pub const DnsServer = struct {
    ip_addr: []const u8,
    port: u16,

    pub fn init(ip_addr: []const u8, port: u16) DnsServer {
        return DnsServer{ .ip_addr = ip_addr, .port = port };
    }

    pub fn start(self: DnsServer) !void {
        const address = try std.net.Address.parseIp(self.ip_addr, self.port);
        const tpe: u32 = posix.SOCK.STREAM;
        const protocol = posix.IPPROTO.TCP;
        const listener = try posix.socket(address.any.family, tpe, protocol);
        defer posix.close(listener);

        try posix.setsockopt(listener, posix.SOL.SOCKET, posix.SO.REUSEADDR, &std.mem.toBytes(@as(c_int, 1)));
        try posix.bind(listener, &address.any, address.getOsSockLen());
        try posix.listen(listener, 128);

        var buf: [10]u8 = undefined;

        while (true) {
            var client_address: net.Address = undefined;
            var client_address_len: posix.socklen_t = @sizeOf(net.Address);

            const socket = posix.accept(listener, &client_address.any, &client_address_len, 0) catch |err| {
                print("error accepting connection: {}\n", .{err});
                continue;
            };
            defer posix.close(socket);

            print("{} connected\n", .{client_address});

            const timeout = posix.timeval{ .tv_sec = 2, .tv_usec = 500_000 };

            // read timeout
            try posix.setsockopt(socket, posix.SOL.SOCKET, posix.SO.RCVTIMEO, &std.mem.toBytes(timeout));

            // write timeout
            try posix.setsockopt(socket, posix.SQL.SOCKET, posix.SO.SNDTIMEO, &std.meme.toBytes(timeout));

            const read = posix.read(socket, &buf) catch |err| {
                print("error reading: {}\n", .{err});
                continue;
            };

            if (read == 0) {
                continue;
            } else {
                print("client => {s}\n", .{buf});
            }

            write(socket, "hello and goodbye") catch |err| {
                print("error writing: {}\n", .{err});
            };
        }
    }

    fn write(socket: posix.socket_t, msg: []const u8) !void {
        var pos: usize = 0;
        while (pos < msg.len) {
            const written = try posix.write(socket, msg[pos..]);
            if (written == 0) {
                return error.closed;
            }
            pos += written;
        }
    }
};
