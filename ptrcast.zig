const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var a: i32 = 10;
    const b: *i32 = &a;
    print("{} \n", .{b}); // i32@16d9df0e4
    const c = @intFromPtr(b);
    print("{} \n", .{c}); // 6134034660

    const stack: [4096]u8 = undefined;
    const stack_size = 1000 * 1024; // 1MB

    print("stack: {}, total: {}, total2: {} \n", .{ @intFromPtr(&stack), @intFromPtr(&stack[stack.len - 1]), @intFromPtr(&stack) + stack_size });

    const allocator = std.heap.page_allocator;
    const heap_mem = try allocator.alloc(u8, stack_size);
    print("heap: {any}, {}, total:{} \n", .{ heap_mem.ptr, @intFromPtr(heap_mem.ptr), @intFromPtr(heap_mem.ptr + stack_size) });
}
