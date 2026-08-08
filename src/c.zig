// this module imporst SDL2 so it can be used on other modules

const std = @import("std");
// Import SDL2 headers here
pub const c = @cImport({
    @cInclude("SDL2/SDL.h");
    // Add other includes like SDL_image if needed later
});

// You can also define common errors here if you want
pub const SDL_ERROR = error{
    SDLInitFailed,
    WindowCreationFailed,
    RendererCreationFailed,
};
