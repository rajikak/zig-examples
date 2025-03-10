const print = @import("std").debug.print;

pub fn main() void {
    // function
    const sum = add(42, 13);
    print("42 + 13 = {d}\n", .{sum});

    // type of string data
    const s1 = "zig";
    const s2 = "is great";
    print("{s} {s}, {}, {}\n", .{ s1, s2, @TypeOf(s1), @TypeOf(s2) });

    // struct
    const user = User{ .power = 9001, .name = "Goku" };
    print("{s}'s power is {d}\n", .{ user.name, user.power });
    user.print2();
}

pub const User = struct {
    power: u64,
    name: []const u8,

    pub const SUPER_POWER = 9000;

    pub fn print2(user: User) void {
        if (user.power >= SUPER_POWER) {
            print("it's over {d}, {s}\n", .{ SUPER_POWER, user.name });
        }
    }
};

fn add(x: i64, y: i64) i64 {
    return x + y;
}
