// THE MAIN FILE WAS GETTING TO MESSY
// SO I PLACED THE ENTITIES STRUCTS HERE INSTEAD
// Also this is a personal preference choice of coding
// I like to code in an object oriented fashion
// so this is something commmon you'll do in Java, so I feel like right at home :)

const c = @import("c.zig").c;

// TILE
pub const Tile = struct {
    x: i32,
    y: i32,
    alive: bool,
    rect: c.SDL_Rect,
    r: u8,
    g: u8,
    b: u8,
};

// PADLE
pub const Paddle = struct {
    x: i32,
    y: i32,
    moving_left: bool,
    moving_right: bool,
    speed: u8,
    rect: c.SDL_Rect,

    pub fn collidesWidth(self: *const Paddle, ball: *const Ball) bool {
        if (ball.x + ball.rect.w < self.x or ball.x > self.x + self.rect.w) {
            return false;
        } else if (ball.y + ball.rect.h < self.y or ball.y > self.y + self.rect.h) {
            return false;
        } else {
            return true;
        }
    }
};

// BALL
pub const Ball = struct {
    x: i32,
    y: i32,
    velocity_x: i32,
    velocity_y: i32,
    rect: c.SDL_Rect,
    pub fn collidesWidth(self: *const Ball, tile: *const Tile) bool {
        if (tile.x + tile.rect.w < self.x or tile.x > self.x + self.rect.w) {
            return false;
        } else if (tile.y + tile.rect.h < self.y or tile.y > self.y + self.rect.h) {
            return false;
        } else {
            return true;
        }
    }
};
