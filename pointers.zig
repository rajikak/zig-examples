const std = @import("std");
const expect = std.testing.expect;

pub fn main() !void {
    std.debug.print("pointers, strings, slices in zig\n", .{});

    // slice is a many item pointer: [*]T with a length of usize.

    var x: u16 = 5;
    increment(&x);
    try expect(x == 6);

    try constPtr();

    try expect(@sizeOf(usize) == @sizeOf(*u8));
    try expect(@sizeOf(isize) == @sizeOf(*u8));

    const hello = "hello, world!";
    const hello2: []const u8 = "hello, world!";
    std.debug.print("len, type: {d}, {any}, {d}, {any}\n", .{ hello.len, @TypeOf(hello), hello2.len, @TypeOf(hello2) });

    const a: []const u8 = "hello";
    const b = a;
    std.debug.print("a.ptr:{*}, b.ptr:{*}\n", .{ a.ptr, b.ptr });

    const immutable_greeting: []const u8 = "hello";
    var buffer: [20]u8 = undefined;
    const mutable_slice = try std.fmt.bufPrint(&buffer, "{s}", .{immutable_greeting});
    std.debug.print("before: {s}, len: {d}, slice: {s}, len: {d}, buffer: {s}, len: {d}\n", .{ immutable_greeting, immutable_greeting.len, mutable_slice, mutable_slice.len, buffer, buffer.len });

    mutable_slice[0] = 'H';
    std.debug.print("after: {s}, len: {d}, slice: {s}, len: {d}, buffer: {s}, len: {d}\n", .{ immutable_greeting, immutable_greeting.len, mutable_slice, mutable_slice.len, buffer, buffer.len });
}

fn increment(num: *u16) void {
    num.* += 1;
}

fn illegalPointer() !void {
    var x: u16 = 5;
    x -= 5;
    const y: *u8 = @ptrFromInt(x); // thread 34859292 panic: cast causes pointer to be null, because can't point to null(0)
    try expect(y.* == 5);
}

fn constPtr() !void {
    const x: u8 = 1;
    const y = &x;
    std.debug.print("pointer: {any}\n", .{@TypeOf(y)});
    // y.* += 1; // cannot assign to constant
}

// many-item pointers
// *T - single imte
// [*]T - multi item
fn doubleAllManyPointer(buffer: [*]u8, byte_count: usize) void {
    var i: usize = 0;
    while (i < byte_count) : (i += 1) buffer[i] *= 2;
}
