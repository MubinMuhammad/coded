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

    pub fn rgbToHsl(rgb: Rgb) Hsl {
        const R: f32, const G: f32, const B: f32 = .{
            rgb.r / 255,
            rgb.g / 255,
            rgb.b / 255,
        };

        const M: f32, const m: f32 = .{
            @max(R, @max(G, B)),
            @min(R, @min(G, B)),
        };

        const C: f32 = M - m;

        var out: Hsl = .{ .h = 0, .s = 0, .l = 0 };

        if (C != 0) {
            if (M == R) out.h = @mod((G - B) / C, 6);
            if (M == G) out.h = (B - R) / C + 2;
            if (M == B) out.h = (R - G) / C + 4;
            out.h *= 60;
        }

        out.l = (M + m) / 2;
        if (C != 0) out.s = C / (1 - @abs(2 * out.l - 1));

        return out;
    }

    pub fn hexToRgb(hex: Hex) Rgb {
        return Rgb{
            .r = (hex >> 16) & 0xFF,
            .g = (hex >> 8) & 0xFF,
            .b = (hex) & 0xFF,
        };
    }

    pub fn strToHex(comptime T: type, str: []const u8) !T {
        if ((!isValidHex(str)) or (@sizeOf(T) * 8 < str.len * 4))
            return ColorError.InvalidHexString;

        var i: i32, var j: i32 = .{ @intCast(str.len - 1), 0 };
        var out: T = 0;

        while (i >= 0) : (i -= 1) {
            out |= @intCast(try hexCharToU8(str[@intCast(i)]) * std.math.pow(i32, 16, j));
            j += 1;
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

test Color {
    try std.testing.expect(try Color.strToHex(Hex, "0997f6") == 0x0997F6);
    try std.testing.expect(try Color.strToHex(Hex, "00ffbf") == 0x00FFBF);
    try std.testing.expect(try Color.strToHex(Hex, "ffffff") == 0xFFFFFF);
    try std.testing.expect(try Color.strToHex(Hex, "daa062") == 0xDAA062);
    try std.testing.expect(try Color.strToHex(u32, "daa0620f") == 0xDAA0620F);
}
