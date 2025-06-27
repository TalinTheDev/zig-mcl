// Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
//! Project root

// Imports
const lib = @import("zig_mcl_lib");
const rl = @import("raylib");
const std = @import("std");

// Game entry point
pub fn main() !void {
    // Initialize window and OpenGL context; Also defer closing both
    rl.initWindow(800, 600, "Hello World!");
    rl.setTargetFPS(60);
    defer rl.closeWindow();

    // While window should stay open...
    while (!rl.windowShouldClose()) {
        // Begin drawing and clear screen
        rl.beginDrawing();
        rl.clearBackground(rl.Color.white);

        // End drawing
        rl.endDrawing();
    }
}
