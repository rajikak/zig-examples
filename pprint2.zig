const std = @import("std");

const MyStruct = struct {
    value1: u32,
    value2: []const u8,

    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt; // Unused in this example
        _ = options; // Unused in this example
        try writer.print("MyStruct(v1: {d}, v2: {s})", .{ self.value1, self.value2 });
    }
};

pub fn main() !void {
    const my_instance = MyStruct{ .value1 = 123, .value2 = "hello" };
    std.debug.print("Custom formatted: {f}\n", .{my_instance});
}
