const std = @import("std");

pub fn main() !void {
    var file: std.fs.File = std.fs.cwd().openFile("test.txt", .{}) catch |e| {
        std.log.err("failed to load file. [{any}]\n", .{e});
        return;
    };
    defer file.close();

    var bufReader = std.io.bufferedReader(file.reader());
    var inStream = bufReader.reader();

    var lineBuf: [1024]u8 = undefined;
    while (try inStream.readUntilDelimiterOrEof(&lineBuf, ' ')) |line| {
        std.debug.print("{s}\n", .{line});
    }
}
