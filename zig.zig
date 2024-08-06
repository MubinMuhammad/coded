const std = @import("std");

pub fn main() !void {
    const a = "/theme gruvboxMaterial   ";
    var itr = std.mem.split(u8, a, " ");

    while (itr.next()) |elem| {
        std.debug.print("'{s}'\n", .{elem});
    }
}
