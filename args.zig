// zig run args.zig -- hello world
const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    print("there are {d} args:\n", .{args.len});
    for (args) |index, arg| {
        print("\t{s}\n", .{arg});
    }
}
