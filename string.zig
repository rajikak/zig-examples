// string ops
const std = @import("std");

pub fn main() !void {
    try join1();
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
