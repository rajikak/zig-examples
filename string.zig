// string ops
const std = @import("std");

pub fn main() !void {
    //try testJoin2();
    try random();
}

fn testJoin2() !void {
    const arg = try join2();
    arg.print();
}

fn random() !void {
    const hosts = [_][]const u8{ "cat", "world", "coffee", "girl", "man", "book" };
    const adjectives = [_][]const u8{ "blue", "red", "green", "yellow", "big", "small" };

    const rand = std.crypto.random;
    const index1 = rand.intRangeAtMost(u8, 1, hosts.len - 1);
    const index2 = rand.intRangeAtMost(u8, 1, adjectives.len - 1);
    std.debug.print("host: {s}-{s}\n", .{ hosts[index1], adjectives[index2] });
}

const Arg = struct {
    n: u8,
    joined: *const []u8,
    list: std.ArrayList([]const u8),

    fn new(n: u8, joined: *const []u8, list: std.ArrayList([]const u8)) Arg {
        return Arg{
            .n = n,
            .joined = joined,
            .list = list,
        };
    }

    fn print(self: Arg) void {
        std.debug.print("Arg {{ n = {d}, joined = {s}, size(list) = {d}}}\n", .{ self.n, self.joined.*, self.list.items.len });
    }
};

fn join2() !Arg {
    var buffer: [1000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    defer fba.reset();

    const allocator = fba.allocator();

    var list: std.ArrayList([]const u8) = .empty;
    try list.append(allocator, "go");
    try list.append(allocator, "build");
    try list.append(allocator, "-tags");
    try list.append(allocator, "lambda.norpc");
    try list.append(allocator, "-o");
    try list.append(allocator, "bootstrap");
    try list.append(allocator, ".");

    const allocator2 = std.heap.page_allocator;
    const joined: []u8 = try std.mem.join(allocator2, ",", list.items);
    std.debug.print("joined: {}, {s}\n", .{ @TypeOf(joined), joined });
    return Arg.new(10, &joined, list);
}

fn join1() !void {
    var buffer: [1000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    defer fba.reset();

    const allocator = fba.allocator();

    var list: std.ArrayList([]const u8) = .empty;
    try list.append(allocator, "go");
    try list.append(allocator, "build");
    try list.append(allocator, "-tags");
    try list.append(allocator, "lambda.norpc");
    try list.append(allocator, "-o");
    try list.append(allocator, "bootstrap");
    try list.append(allocator, ".");

    const joined = try std.mem.join(allocator, ",", list.items);
    std.debug.print("joined: {s}\n", .{joined});
}
