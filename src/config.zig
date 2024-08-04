const std = @import("std");

const Config = struct {
    setBuf: std.BufMap,
    changeBuf: std.BufMap,
    pathBuf: std.BufMap,
    themesBuf: std.BufMap,

    pub fn init(configPath: []const u8, internalConfigPath: []const u8) !Config {
        var file = try std.fs.cwd().openFile(configPath, .{});
        defer file.close();

        var bufReader = std.io.bufferedReader(file.reader());
        var inputStream = bufReader.reader();

        var lineBuf: [1024]u8 = undefined;

        while (try inputStream.readUntilDelimiterOrEof(&lineBuf, " ")) |line| {}
    }
};
