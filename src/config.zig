const std = @import("std");

const ConfigError = error{
    EmptyLine,
    InvalidCommand,
    NotEnoughArgs,
};

const Config = struct {
    setBuf: std.BufMap,
    changeBuf: std.BufMap,
    themeBuf: std.BufMap,
    pathBuf: std.BufMap,

    pub fn init(configPath: []const u8, internalConfigPath: []const u8) !Config {
        var file = try std.fs.cwd().openFile(configPath, .{});
        defer file.close();

        var bufReader = std.io.bufferedReader(file.reader());
        var inputStream = bufReader.reader();

        var lineBuf: [1024]u8 = undefined;

        while (try inputStream.readUntilDelimiterOrEof(&lineBuf, " ")) |line| {}
    }

    pub fn deinit(self: *Config) void {
        self.*.pathBuf.deinit();
        self.*.changeBuf.deinit();
        self.*.themeBuf.deinit();
        self.*.pathBuf.deinit();
    }

    fn initConfig(cfg: *Config) void {
        cfg.*.setBuf = std.BufMap.init(std.heap.page_allocator);
        cfg.*.changeBuf = std.BufMap.init(std.heap.page_allocator);
        cfg.*.themeBuf = std.BufMap.init(std.heap.page_allocator);
        cfg.*.pathBuf = std.BufMap.init(std.heap.page_allocator);
    }

    fn getCommandArgs(line: []const u8, cfg: *Config) void {}
};
