// nc  localhost 8443
// non-blocking server with poll

const std = @import("std");
const net = std.net;
const posix = std.posix;

pub fn main() !void {
    const server = DnsServer.init("127.0.0.1", 8443);
    try server.start();
    std.debug.print("dns server is ready\n", .{});
}

pub const DnsServer = struct {
    ip_addr: []const u8,
    port: u16,

    pub fn init(ip_addr: []const u8, port: u16) DnsServer {
        return DnsServer{ .ip_addr = ip_addr, .port = port };
    }

    pub fn start(self: DnsServer) !void {
        const address = try std.net.Address.parseIp(self.ip_addr, self.port);
        const tpe: u32 = posix.SOCK.STREAM | posix.SOCK.NONBLOCK;
        const protocol = posix.IPPROTO.TCP;
        const listener = try posix.socket(address.any.family, tpe, protocol);
        defer posix.close(listener);

        try posix.setsockopt(listener, posix.SOL.SOCKET, posix.SO.REUSEADDR, &std.mem.toBytes(@as(c_int, 1)));
        try posix.bind(listener, &address.any, address.getOsSockLen());
        try posix.listen(listener, 128);

        var polls: [4096]posix.pollfd = undefined;
        polls[0] = .{
            .fd = listener,
            .events = posix.POLL.IN,
            .revents = 0,
        };

        var poll_count: usize = 1;

        while (true) {
            var active = polls[0 .. poll_count + 1];
            _ = try posix.poll(active, -1);

            if (active[0].revents != 0) { // active[0] is the listening socket
                var client_address: net.Address = undefined;
                var client_address_len: posix.socklen_t = @sizeOf(net.Address);

                const socket = try posix.accept(listener, &client_address.any, &client_address_len, posix.SOCK.NONBLOCK);

                polls[poll_count] = .{
                    .fd = socket,
                    .revents = 0,
                    .events = posix.POLL.IN,
                };

                poll_count += 1;
            }

            var i: usize = 1;
            while (i < active.len) {
                const polled = active[i];

                const revents = polled.revents;
                if (revents == 0) {
                    //not ready yet
                    i += 1;
                    continue;
                }
                var closed = false;
                if (revents & posix.POLL.IN == posix.POLL.IN) {
                    // socket is ready for polling
                    var buf: [4096]u8 = undefined;
                    const read = posix.read(polled.fd, &buf) catch 0;
                    if (read == 0) {
                        closed = true;
                    } else {
                        std.debug.print("[{d}] got: {any}\n", .{ polled.fd, buf[0..read] });
                    }
                }

                if (closed or (revents & posix.POLL.HUP == posix.POLL.HUP)) {
                    // read failed or socket is closed
                    posix.close(polled.fd);

                    const last_index = active.len - 1;
                    active[i] = active[last_index];
                    active = active[0..last_index];
                    poll_count = 1;
                } else {
                    i += 1; // go to the next socket
                }
            }
        }
    }
};
