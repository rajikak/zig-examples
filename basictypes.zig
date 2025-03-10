const print = @import("std").debug.print;

pub fn main() void {
    const byte = "hello";
    const is_true = false;
    const v1: u64 = 1 << 64 - 1;
    const v2: u128 = 1 << 64 - 1;
    const v3: i8 = -1;
    const u = '💯';

    print("{s}, {}\n", .{ byte, @TypeOf(byte) });
    print("{}, {}\n", .{ is_true, @TypeOf(is_true) });
    print("{}, {}\n", .{ v1, @TypeOf(v1) });
    print("{}, {}\n", .{ v2, @TypeOf(v2) });
    print("{}, {}\n", .{ v3, @TypeOf(v3) });
    print("{u}, {}\n", .{ u, @TypeOf(u) });
}
