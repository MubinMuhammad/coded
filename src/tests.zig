const std = @import("std");

const Color = @import("colors.zig").Color;
const Hex = @import("colors.zig").Hex;
const Rgb = @import("colors.zig").Rgb;
const Hsl = @import("colors.zig").Hsl;
const ColorError = @import("colors.zig").ColorError;

test Color {
    try std.testing.expect(try Color.strToHex("0997f6") == 0x0997F6);
    try std.testing.expect(try Color.strToHex("00ffbf") == 0x00FFBF);
    try std.testing.expect(try Color.strToHex("ffffff") == 0xFFFFFF);
    try std.testing.expect(try Color.strToHex("daa062") == 0xDAA062);
    try std.testing.expect(try Color.strToHex("daa062") == 0xDAA062);
    try std.testing.expect(try Color.strToHex("101010") == 0x101010);

    try std.testing.expect(std.meta.eql(Color.hexToRgb(0xFFFFFF), Rgb{ .r = 255, .g = 255, .b = 255 }));
    try std.testing.expect(std.meta.eql(Color.hexToRgb(0x6E00FF), Rgb{ .r = 110, .g = 0, .b = 255 }));
    try std.testing.expect(std.meta.eql(Color.hexToRgb(0x00D4FF), Rgb{ .r = 0, .g = 212, .b = 255 }));
    try std.testing.expect(std.meta.eql(Color.hexToRgb(0x40BF46), Rgb{ .r = 64, .g = 191, .b = 70 }));
    try std.testing.expect(std.meta.eql(Color.hexToRgb(0xC4D572), Rgb{ .r = 196, .g = 213, .b = 114 }));

    try std.testing.expect(Color.rgbToHex(Rgb{ .r = 255, .g = 255, .b = 255 }) == 0xFFFFFF);
    try std.testing.expect(Color.rgbToHex(Rgb{ .r = 110, .g = 0, .b = 255 }) == 0x6E00FF);
    try std.testing.expect(Color.rgbToHex(Rgb{ .r = 0, .g = 212, .b = 255 }) == 0x00D4FF);
    try std.testing.expect(Color.rgbToHex(Rgb{ .r = 64, .g = 191, .b = 70 }) == 0x40BF46);
    try std.testing.expect(Color.rgbToHex(Rgb{ .r = 196, .g = 213, .b = 114 }) == 0xC4D572);

    // I Didn't know how to do with HSL tests.
    // So, I just checked if the results of Color.rgbToHsl() and
    // Color.hslToRgb() match with hslpicker.com, and It did.
    //
    // NOTE: the `s`, 'l' will be in range of 0 to 1 in
    // Color.rgbToHsl().
}
