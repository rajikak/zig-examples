const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    try arrayListTest(alloc);
}

fn arrayListTest(allocator: Allocator) !void {
    var list: std.ArrayList([]const u8) = .empty;
    defer list.deinit(allocator);

    try list.append(allocator, "hello");
    try list.append(allocator, "world");
    try list.append(allocator, "from");
    try list.append(allocator, "zig");
    try list.append(allocator, "lang");

    std.debug.print("cap: {d}\n", .{list.capacity});
    for (list.items) |item| {
        std.debug.print("{s}\n", .{item});
    }
}
