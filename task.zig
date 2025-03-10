// a task scheduler
const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main() !void {
    //var person = Person{ .name = "Vegeta" };
    //const thread = try std.Thread.spawn(.{}, Person.say, .{ &person, "limit exceed", 3 * std.time.ns_per_s });
    //thread.join();

    var buf: [100]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    const allocator = fba.allocator();

    var s = Scheduler(Task).init(allocator);
    defer s.deinit();

    try s.start();
    var person = Person{ .name = "nrk" };
    try s.scheduleIn(.{ .say = .{ .person = &person, .msg = "over 9000!" } }, 8000);
}

const Person = struct {
    name: []const u8,

    fn say(p: *Person, msg: []const u8, when: u64) void {
        while (true) {
            std.time.sleep(when);
            std.debug.print("{s} said: {s} \n", .{ p.name, msg });
        }
    }
};

const Task = union(enum) {
    say: Say,
    db_cleaner: void,

    const Say = struct {
        person: *Person,
        msg: []const u8,
    };

    pub fn run(task: Task) void {
        switch (task) {
            .say => |s| std.debug.print("{s} said: {s}\n", .{ s.person.name, s.msg }),
            .db_cleaner => {
                std.debug.print("cleaning old records from the database\n", .{});
            },
        }
    }
};

fn Job(comptime T: type) type {
    return struct {
        task: T,
        run_at: i64,
    };
}

fn Scheduler(comptime T: type) type {
    return struct {
        queue: Queue,
        allocator: Allocator,

        const Self = @This();

        const Queue = std.DoublyLinkedList(Job(T));

        pub fn init(allocator: Allocator) Self {
            return .{
                .queue = Queue{},
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            while (self.queue.pop()) |node| {
                self.allocator.destroy(node);
            }
        }

        pub fn schedule(self: *Self, task: T, run_at: i64) !void {
            const node = try self.allocator.create(Queue.Node);
            node.data = Job(T){
                .task = task,
                .run_at = run_at,
            };
            self.queue.append(node);
        }

        pub fn scheduleIn(self: *Self, task: T, ms: i64) !void {
            return self.schedule(task, std.time.milliTimestamp() + ms);
        }

        pub fn start(self: *Self) !void {
            const thread = try std.Thread.spawn(.{}, Self.run, .{self});
            thread.join();
        }

        fn run(self: *Self) void {
            while (true) {
                const ms = self.timeUntilNextTask() orelse 1000;
                std.time.sleep(@intCast(ms * std.time.ns_per_ms));

                const first = self.queue.first orelse {
                    // queue is empty, go back and star the loop
                    continue;
                };

                const job = first.data;
                if (job.run_at > std.time.milliTimestamp()) {
                    // go back and start the loop again
                    continue;
                }

                self.queue.remove(first);
                self.allocator.destroy(first);
                job.task.run();
            }
        }

        fn timeUntilNextTask(self: *Self) ?i64 {
            if (self.queue.first) |first| {
                return std.time.milliTimestamp() - first.data.run_at;
            }
            return null;
        }
    };
}
