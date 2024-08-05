const std = @import("std");

pub const ConfigError = error{
    InvalidCommand,
    TooFewArgs,
    TooManyArgs,
};

pub const Config = struct {
    setBuf: std.BufMap,
    theme: []const u8,
    themeType: []const u8,
    themeCallibration: bool,
    paths: std.BufMap,
    colorSchemes: std.BufMap,

    pub fn init(configPath: []const u8) !Config {
        var cfg: Config = undefined;
        initConfig(&cfg);

        var file = try std.fs.cwd().openFile(configPath, .{});
        defer file.close();

        var bufReader = std.io.bufferedReader(file.reader());
        var inputStream = bufReader.reader();

        var lineBuf: [1024]u8 = undefined;

        while (try inputStream.readUntilDelimiterOrEof(&lineBuf, '\n')) |line| {
            var k: u32 = 0;
            for (line) |c| {
                if (c == '#') break;
                k += 1;
            }

            try getCommandArgs(line[0..k], &cfg);
        }

        return cfg;
    }

    pub fn deinit(self: *Config) void {
        self.*.setBuf.deinit();
        self.*.colorSchemes.deinit();
        self.*.paths.deinit();
    }

    fn initConfig(cfg: *Config) void {
        cfg.*.setBuf = std.BufMap.init(std.heap.page_allocator);
        cfg.*.colorSchemes = std.BufMap.init(std.heap.page_allocator);
        cfg.*.paths = std.BufMap.init(std.heap.page_allocator);
    }

    fn getCommandArgs(line: []const u8, cfg: *Config) !void {
        if (line.len == 0)
            return;

        var tkn = std.mem.split(u8, line, " ");

        var command = std.ArrayList(u8).init(std.heap.page_allocator);
        defer command.deinit();

        if (tkn.peek().?.len == 1 and tkn.peek().?[0] == '/') {
            _ = tkn.next();
            try command.appendSlice(tkn.next().?);
        } else {
            try command.appendSlice(tkn.next().?[1..]);
        }

        if (std.mem.eql(u8, command.items, "set")) {
            try cfg.*.setBuf.put(tkn.next().?, tkn.next().?);
        } else if (std.mem.eql(u8, command.items, "theme")) {
            cfg.*.theme = tkn.next().?;
        } else if (std.mem.eql(u8, command.items, "themeType")) {
            cfg.*.themeType = tkn.next().?;
        } else if (std.mem.eql(u8, command.items, "themeCallibration")) {
            cfg.*.themeCallibration = if (std.mem.eql(u8, tkn.next().?, "true")) true else false;
        } else if (std.mem.eql(u8, command.items, "addPath")) {
            try cfg.*.paths.put(tkn.next().?, tkn.next().?);
        } else if (std.mem.eql(u8, command.items, "addTheme")) {
            try cfg.*.colorSchemes.put(tkn.next().?, tkn.next().?);
        } else {
            return error.InvalidCommand;
        }

        // NOTE: Not working because of trailing spaces.
        if (tkn.peek() != null) return error.TooManyArgs;
    }
};
