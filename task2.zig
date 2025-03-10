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
        mutex: std.Thread.Mutex,
        cond: std.Thread.Condition,

        const Self = @This();

        const Queue = std.PriorityQueue(Job(T), void, compare);

        fn compare(_: void, a: Job(T), b: Job(T)) std.math.Order {
            return std.math.order(a.run_at, b.run_at);
        }

        pub fn init(allocator: Allocator) Self {
            return .{
                .cond = .{},
                .mutex = .{},
                .queue = Queue.init(allocator, {}),
            };
        }

        pub fn deinit(self: *Self) void {
            self.queue.deinit();
        }

        pub fn schedule(self: *Self, task: T, run_at: i64) !void {
            const job = Job(T){
                .task = task,
                .run_at = run_at,
            };
            self.mutex.lock();
            defer self.mutex.unlock();

            var reschedule = false;
            if (self.queue.peek()) |*next| {
                if (run_at < next.run_at) {
                    reschedule = true;
                }
            } else {
                reschedule = true;
            }

            try self.queue.add(job);
            if (reschedule) {
                self.cond.signal(); // signal that a job is added
            }
        }

        pub fn scheduleIn(self: *Self, task: T, ms: i64) !void {
            return self.schedule(task, std.time.milliTimestamp() + ms);
        }

        pub fn start(self: *Self) !void {
            const thread = try std.Thread.spawn(.{}, Self.run, .{self});
            thread.detach();
        }

        fn run(self: *Self) void {
            while (true) {
                self.mutex.lock();
                if (self.timeUntilNextTask()) |ms| {
                    if (ms > 0) {
                        const ns: u64 = @intCast(std.time.ns_per_ms * ms);
                        self.cond.timedWait(&self.mutex, ns) catch |err| {
                            std.debug.assert(err == error.Timeout);
                        };
                    }
                } else {
                    self.cond.wait(&self.mutex);
                }
                while (self.queue.peek() == null) {
                    self.cond.wait(&self.mutex);
                }

                const next = self.queue.peek() orelse continue;

                if (next.run_at > std.time.milliTimestamp()) {
                    continue;
                }

                const job = self.queue.remove();
                self.mutex.unlock();
                job.task.run();
            }
        }

        fn timeUntilNextTask(self: *Self) ?i64 {
            if (self.queue.peek()) |*next| {
                return next.run_at - std.time.milliTimestamp();
            }
            return null;
        }
    };
}
