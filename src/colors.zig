// Each color strcut will contain4 values RGBA
const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
};

// you can use integers instead of hex values, hex are optional on SDL2
// just make sure, if you are going to use ints it goes from 0 - 255
// I used hex here to demonstrate that you are free to use them, and it makes the struct cleaner
pub const colors = [_]Color{
    .{ .r = 0xFF, .g = 0x00, .b = 0x00, .a = 0xFF }, // Red
    .{ .r = 0xFF, .g = 0xA5, .b = 0x00, .a = 0xFF }, // Orange
    .{ .r = 0xFF, .g = 0xFF, .b = 0x00, .a = 0xFF }, // Yellow
    .{ .r = 0x00, .g = 0x80, .b = 0x00, .a = 0xFF }, // Green
    .{ .r = 0x00, .g = 0xFF, .b = 0xFF, .a = 0xFF }, // Cyan
    .{ .r = 0x00, .g = 0x00, .b = 0xFF, .a = 0xFF }, // Blue
    .{ .r = 0x64, .g = 0x50, .b = 0xEE, .a = 0xFF }, // Violet
};
