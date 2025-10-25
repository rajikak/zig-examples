const std = @import("std");

const Status = enum {
    Ok,
    Warning,
    Error,

    pub fn format(self: Status, writer: anytype) !void {
        const label = switch (self) {
            .Ok => "✅ OK",
            .Warning => "⚠️  Warning",
            .Error => "❌ Error",
        };
        try writer.print("{s}", .{label});
    }
};

const Point = struct {
    x: f32,
    y: f32,

    // format v1
    //pub fn format(self: Point, writer: anytype) !void {
    //    try writer.print("Point(x = {}, y = {})", .{ self.x, self.y });
    //}

    // format v2
    //pub fn format(self: Point, writer: anytype) !void {
    //    try writer.print("Point(x = {:.3}, y = {:.6})", .{ self.x, self.y });
    //}

    // format v3
    pub fn format(self: Point, writer: anytype) !void {
        try writer.print("Point(x = {[x1]:[w]}, y = {[y1]})", .{ .x1 = self.x, .w = 10, .y1 = self.y });
    }
};

pub fn main() !void {
    const s1 = Status.Ok;
    const s2 = Status.Warning;
    const s3 = Status.Error;
    std.debug.print("{f} {f} {f}\n", .{ s1, s2, s3 });

    const p = Point{ .x = 5.101212, .y = 10.121212 };

    std.debug.print("{f}\n", .{p}); // format v1, v2, v3
}
