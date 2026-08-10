const std = @import("std");
const c = @import("c.zig").c; // this module calls SDL.h from the C library
const app_module = @import("app.zig");
const App = app_module.App; // we will handle SDL2 init prosscess with this App module
const Entities = @import("entities.zig");
const Colors = @import("colors.zig");

const WINDOW_WIDHT: i32 = 1080;
const WINDOW_HEIGHT: i32 = 720;

pub fn main() !void {
    // Initialize SDL2
    var app = try App.init(WINDOW_WIDHT, WINDOW_HEIGHT, "SDL2 Breakout in Zig By: Lu");
    defer app.deinit();

    // how many tiles will be created
    const rows: u32 = Colors.colors.len;
    const columns: u32 = @divTrunc(WINDOW_WIDHT, 90);

    // once we decide the rows and columns,
    // multipy it to have an exact amount in the array
    const amount: u32 = rows * columns;
    var tiles: [amount]Entities.Tile = undefined;

    // iterate trough each tile in the array
    // and based on the nested for loops asign and x and y
    // along with a color from the colors array in colors.zig each row will be a different color
    var counter: u32 = 0;
    for (0..rows) |i| {
        for (0..columns) |j| {
            tiles[counter] = Entities.Tile{
                .x = @intCast(j * 91),
                .y = @intCast(i * 11),
                .alive = true,
                .rect = c.SDL_Rect{ .x = 0, .y = 0, .w = 90, .h = 10 },
                .r = Colors.colors[i].r,
                .g = Colors.colors[i].g,
                .b = Colors.colors[i].b,
            };
            counter += 1;
        }
    }

    // create the main player
    const initial_x = (WINDOW_WIDHT / 2);
    const initial_y = 600;

    var player = Entities.Paddle{
        .x = initial_x - 100,
        .y = initial_y,
        .moving_left = false,
        .moving_right = false,
        .speed = 12,
        .rect = c.SDL_Rect{
            .x = initial_x,
            .y = initial_y,
            .w = 150,
            .h = 10,
        },
    };

    // create the ball
    var ball = Entities.Ball{
        .x = initial_x,
        .y = 500,
        .velocity_x = 2,
        .velocity_y = -4,
        .rect = c.SDL_Rect{ .x = initial_x, .y = 500, .w = 10, .h = 10 },
    };

    // main loop
    var is_running = true;
    while (is_running) {
        // get the SDL events, what happens if user clics the [X] or if ESC is pressed
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            if (event.type == c.SDL_QUIT) is_running = false;
            if (event.type == c.SDL_KEYDOWN and event.key.keysym.sym == c.SDLK_ESCAPE) {
                is_running = false;
            }
            // controls, left and right arrow
            if (event.type == c.SDL_KEYDOWN and event.key.keysym.sym == c.SDLK_RIGHT) {
                player.moving_right = true;
            } else if (event.type == c.SDL_KEYUP and event.key.keysym.sym == c.SDLK_RIGHT) {
                player.moving_right = false;
            }

            if (event.type == c.SDL_KEYDOWN and event.key.keysym.sym == c.SDLK_LEFT) {
                player.moving_left = true;
            } else if (event.type == c.SDL_KEYUP and event.key.keysym.sym == c.SDLK_LEFT) {
                player.moving_left = false;
            }
        }

        // ### COLLISION DETECTION ###################################

        // prevents the player from going out of bounds
        if (player.x <= 0) {
            player.x = 0;
        } else if (player.x + player.rect.w >= WINDOW_WIDHT) {
            player.x = WINDOW_WIDHT - player.rect.w;
        }

        // prevents the ball from going out of bounds
        if (ball.x > WINDOW_WIDHT - ball.rect.w) {
            ball.velocity_x *= -1;
        } else if (ball.x < 0) {
            ball.velocity_x *= -1;
        }

        // if the ball goes out of bounds fromt the bottom of the screen
        // reposition it to the center of the screen (take 1 life away, not implemented but add it here)
        if (ball.y > WINDOW_HEIGHT + 600) {
            ball.x = WINDOW_WIDHT / 2;
            ball.y = WINDOW_HEIGHT / 2;
            ball.velocity_y *= -1;
        } else if (ball.y < 0) {
            ball.velocity_y *= -1;
        }

        // if the player collides with the ball, makes the ball bounce
        if (player.collidesWidth(&ball)) {
            if (ball.y < player.y) {
                ball.velocity_y *= -1;
            }
            if (ball.y > player.y) {
                ball.velocity_y *= -1;
            }
        }

        // iterate trough the tiles array, and check 1 by 1 if the tile is alive,
        // if it is, proceed, and check if the ball collides with the current tile
        // if it does, proceed and make the ball bounce, and the current tile will no longer be alive
        for (&tiles) |*current_tile| {
            if (current_tile.alive) {
                if (ball.collidesWidth(current_tile)) {
                    if (ball.y < current_tile.y) {
                        ball.velocity_y *= -1;
                        current_tile.alive = false;
                    } else if (ball.y > current_tile.y) {
                        ball.velocity_y *= -1;
                        current_tile.alive = false;
                    }
                }
            }
        }

        // ### UPDATE ################################################
        if (player.moving_right) {
            player.x += player.speed;
        }
        if (player.moving_left) {
            player.x -= player.speed;
        }

        ball.x += ball.velocity_x;
        ball.y += ball.velocity_y;

        // updating the SDL rects
        player.rect.x = player.x;
        ball.rect.x = ball.x;
        ball.rect.y = ball.y;

        // ### RENDER ####################################################
        // background
        App.enforce(c.SDL_SetRenderDrawColor(app.renderer, 23, 45, 68, 255));
        App.enforce(c.SDL_RenderClear(app.renderer));

        // iterate trought the array of tiles,
        // check if the tile is still alive
        // and place the rect of each tile from it's coordinates
        // and call the render functions, before the render buffers swap
        for (&tiles) |*tile| {
            if (tile.alive) {
                tile.rect.x = tile.x;
                tile.rect.y = tile.y;
                App.enforce(c.SDL_SetRenderDrawColor(app.renderer, tile.r, tile.g, tile.b, 255));
                App.enforce(c.SDL_RenderFillRect(app.renderer, &tile.rect));
            }
        }

        // RENDER THE BALL
        App.enforce(c.SDL_SetRenderDrawColor(app.renderer, 255, 255, 255, 255));
        App.enforce(c.SDL_RenderFillRect(app.renderer, &ball.rect));

        // RENDER THE PADDLE
        App.enforce(c.SDL_SetRenderDrawColor(app.renderer, 255, 255, 255, 255));
        App.enforce(c.SDL_RenderFillRect(app.renderer, &player.rect));

        // DELAY
        c.SDL_RenderPresent(app.renderer);
        c.SDL_Delay(10);
        // #############################################################
    }
}
