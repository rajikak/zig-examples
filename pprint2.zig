const std = @import("std");

const Name = struct {
    value: []const u8,

    pub fn format(self: Name, writer: anytype) !void {
        try writer.print("{s}", .{self.value});
    }
};

const Point = struct {
    x: f32,
    y: f32,
    name: Name,

    pub fn format(self: Point, writer: anytype) !void {
        //try writer.print("Point(x = {[x1]:[w]}, y = {[y1]}, ", .{ .x1 = self.x, .w = 10, .y1 = self.y });
        try writer.print("name = {f})", self.name);
    }
};

pub fn main() !void {
    const z = Name{ .value = "zero" };
    const p = Point{ .x = 5.101212, .y = 10.121212, .name = z };

    std.debug.print("{f}\n", .{p}); // format v1, v2, v3
}
