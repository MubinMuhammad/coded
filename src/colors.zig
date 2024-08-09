const std = @import("std");

pub const Hex = u24;
pub const Rgb = struct { r: u8, g: u8, b: u8 };
pub const Hsl = struct { h: f32, s: f32, l: f32 };
pub const ColorError = error{InvalidHexString};

pub const Color = struct {
    hex: Hex,
    rgb: Rgb,
    hsl: Hsl,

    pub fn init(hexStr: []const u8) !Color {
        if (hexStr.len != 6) return ColorError.InvalidHexString;

        const out: Color = undefined;
        out.hex = strToHex(Hex, hexStr);
    }

    pub fn hslToRgb(hsl: Hsl) Rgb {
        const C = (1 - @abs(2 * hsl.l - 1)) * hsl.s;
        const X = C * (1 - @abs(@mod(hsl.h / 60, 2) - 1));
        const m = hsl.l - C / 2;
        var out: [3]f32 = undefined;

        if (0 <= hsl.h and hsl.h < 60) {
            out[0] = C;
            out[1] = X;
            out[2] = 0.0;
        } else if (60 <= hsl.h and hsl.h < 120) {
            out[0] = X;
            out[1] = C;
            out[2] = 0.0;
        } else if (120 <= hsl.h and hsl.h < 180) {
            out[0] = 0.0;
            out[1] = C;
            out[2] = X;
        } else if (180 <= hsl.h and hsl.h < 240) {
            out[0] = 0.0;
            out[1] = X;
            out[2] = C;
        } else if (240 <= hsl.h and hsl.h < 300) {
            out[0] = X;
            out[1] = 0.0;
            out[2] = C;
        } else if (300 <= hsl.h and hsl.h <= 360) {
            out[0] = C;
            out[1] = 0.0;
            out[2] = X;
        }

        return Rgb{
            .r = @as(u8, @intFromFloat((out[0] + m) * 255)),
            .g = @as(u8, @intFromFloat((out[1] + m) * 255)),
            .b = @as(u8, @intFromFloat((out[2] + m) * 255)),
        };
    }

    pub fn rgbToHsl(rgb: Rgb) Hsl {
        const R: f32, const G: f32, const B: f32 = .{
            @as(f32, @floatFromInt(rgb.r)) / 255.0,
            @as(f32, @floatFromInt(rgb.g)) / 255.0,
            @as(f32, @floatFromInt(rgb.b)) / 255.0,
        };

        const M: f32, const m: f32 = .{
            @max(R, @max(G, B)),
            @min(R, @min(G, B)),
        };

        const C: f32 = M - m;

        var out: Hsl = .{ .h = 0, .s = 0, .l = 0 };

        out.l = (M + m) / 2.0;

        if (C != 0.0) {
            out.s = C / (1.0 - @abs(2 * out.l - 1.0));

            if (M == R) out.h = @mod((G - B) / C, 6.0);
            if (M == G) out.h = (B - R) / C + 2.0;
            if (M == B) out.h = (R - G) / C + 4.0;
            out.h *= 60.0;
        }

        return out;
    }

    pub fn rgbToHex(rgb: Rgb) Hex {
        var hex: Hex = 0;

        hex |= (@as(u24, rgb.r) << 16) & 0xFF0000;
        hex |= (@as(u24, rgb.g) << 8) & 0x00FF00;
        hex |= (@as(u24, rgb.b)) & 0x0000FF;

        return hex;
    }

    pub fn hexToRgb(hex: Hex) Rgb {
        return Rgb{
            .r = @truncate((hex >> 16) & 0xFF),
            .g = @truncate((hex >> 8) & 0xFF),
            .b = @truncate((hex) & 0xFF),
        };
    }

    pub fn strToHex(str: []const u8) !Hex {
        if ((!isValidHex(str)) or (str.len != 6)) return ColorError.InvalidHexString;

        var i: isize = 5;
        var out: Hex = 0;

        while (i >= 0) : (i -= 1) {
            out |= @intCast(try hexCharToU8(str[@intCast(i)]) * std.math.pow(isize, 16, 5 - i));
        }

        return out;
    }

    fn hexCharToU8(c: u8) !u8 {
        return switch (c) {
            '0'...'9' => c - '0',
            'a'...'z' => (c - 'a') + 10,
            'A'...'Z' => (c - 'A') + 10,
            else => ColorError.InvalidHexString,
        };
    }

    fn isValidHex(str: []const u8) bool {
        for (str) |c| if (!std.ascii.isHex(c)) return false;
        return true;
    }
};
