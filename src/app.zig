// This module initializes the window and the renderer
// it will also implement enfoce
// all enofce() does, it handles the int return errors so we can replace _ = on main
// you don't have to do this, but when I work with SDL in C++
// I preffer to create a seperate file that handles the SDL2 init and the creation of the window and renderer
// my reason for doing this, in the future, once you  keep adding more SDL2 features
// you main file will be way too messy, specially in C++, so this is a way I found out to handle all that mess

const std = @import("std");
const c = @import("c.zig").c;
const AppError = @import("c.zig").SDL_ERROR;

pub const App = struct {
    window: ?*c.SDL_Window,
    renderer: ?*c.SDL_Renderer,

    // create the window and the renderer,
    // handle the errors
    pub fn init(window_width: i32, window_height: i32, title: []const u8) AppError!App {
        if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
            return AppError.SDLInitFailed;
        }
        // SDL REFERENCE CODE IN C:
        // SDL_Window * SDL_CreateWindow(const char *title, int x, int y, int w, int h, Uint32 flags);
        const window = c.SDL_CreateWindow(
            title.ptr,
            c.SDL_WINDOWPOS_CENTERED,
            c.SDL_WINDOWPOS_CENTERED,
            window_width,
            window_height,
            c.SDL_WINDOW_SHOWN,
        ) orelse return AppError.WindowCreationFailed;

        const renderer = c.SDL_CreateRenderer(
            window,
            -1,
            c.SDL_RENDERER_ACCELERATED,
        ) orelse return AppError.RendererCreationFailed;

        return App{
            .window = window,
            .renderer = renderer,
        };
    }

    pub fn enforce(ret: c_int) void {
        if (ret != 0) {
            std.log.err("SDL Error: {s}", .{c.SDL_GetError()});
            unreachable;
        }
    }

    pub fn deinit(self: *App) void {
        if (self.renderer) |r| c.SDL_DestroyRenderer(r);
        if (self.window) |w| c.SDL_DestroyWindow(w);
        c.SDL_Quit();
    }
};
