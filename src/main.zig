const std = @import("std");
const coded = @import("coded.zig");

pub fn main() !void {
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.process.argsFree(std.heap.page_allocator, args);

    var cfg = coded.Config.init("CodedConfig") catch |e| {
        std.debug.print("Error loading config! [{?}]\n", .{e});
        return;
    };
    defer cfg.deinit();

    var itr = cfg.setBuf.iterator();
    while (itr.next()) |elem| {
        std.debug.print("{s}: {s}\n", .{ elem.key_ptr.*, elem.value_ptr.* });
    }
}
