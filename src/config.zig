const std = @import("std");

pub const ConfigError = error{
    InvalidCommand,
    TooFewArgs,
    TooManyArgs,
};

pub const Config = struct {
    setBuf: std.BufMap,
    themeBuf: []const u8,
    pathBuf: std.BufMap,

    // for later, this argument, internalConfigPath: []const u8
    pub fn init(configPath: []const u8) !Config {
        var cfg: Config = undefined;
        initConfig(&cfg);

        var file = try std.fs.cwd().openFile(configPath, .{});
        defer file.close();

        var bufReader = std.io.bufferedReader(file.reader());
        var inputStream = bufReader.reader();

        var lineBuf: [1024]u8 = undefined;

        while (try inputStream.readUntilDelimiterOrEof(&lineBuf, '\n')) |line| {
            std.debug.print("{s}\n", .{line});
            try getCommandArgs(line, &cfg);
        }

        return cfg;
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

    fn getCommandArgs(line: []const u8, cfg: *Config) !void {
        if (line.len == 0)
            return;

        var tkn = std.mem.split(u8, line, " ");

        if (tkn.peek().?[0] == '#')
            return;

        var command = std.ArrayList(u8).init(std.heap.page_allocator);
        defer command.deinit();

        if (tkn.peek().?.len == 1 and tkn.peek().?[0] == '/') {
            try command.appendSlice(tkn.next().?);
            try command.appendSlice(tkn.next().?);
        } else {
            try command.appendSlice(tkn.next().?);
        }

        const storeBuf: *std.BufMap = try getBuf(command.items, cfg);
        var keyVal: [2][128]u8 = undefined;
        var k: u8 = 0;

        while (tkn.next()) |elem| {
            std.mem.copyForwards(u8, &keyVal[k], elem);
            if (elem[0] == '#' or k >= 1) break;
            k += 1;
        }

        if (k < 1) return error.TooFewArgs;
        if (tkn.next() != null and tkn.peek().?[0] != '#') return error.TooManyArgs;

        try storeBuf.*.put(&keyVal[0], &keyVal[1]);
    }

    fn getBuf(command: []const u8, cfg: *Config) !*anyopaque {
        if (std.mem.eql(u8, command[1..], "set")) {
            return &cfg.*.setBuf;
        } else if (std.mem.eql(u8, command[1..], "changeTheme")) {
            return &cfg.*.themeBuf;
        } else if (std.mem.eql(u8, command[1..], "addPath")) {
            return &cfg.*.pathBuf;
        } else {
            return error.InvalidCommand;
        }
    }
};
