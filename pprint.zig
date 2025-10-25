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
    x: i32,
    y: i32,

    pub fn format(self: Point, writer: anytype) !void {
        try writer.print("Point({}, {})", .{ self.x, self.y });
    }
};

pub fn main() !void {
    const s1 = Status.Ok;
    const s2 = Status.Warning;
    const s3 = Status.Error;
    const p = Point{ .x = 5, .y = 10 };

    std.debug.print("{f} {f} {f}\n", .{ s1, s2, s3 });
    std.debug.print("{f}\n", .{p});
}
