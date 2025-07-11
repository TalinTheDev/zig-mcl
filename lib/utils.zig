// Copyright 2025 Talin Sharma and Alex Oh. Subject to the Apache-2.0 license.
//! Contains utility functions used in this project

// Imports
const rl = @import("raylib");

/// Convert an integer (any int type) to a float (f32)
pub fn itf(int: anytype) f32 {
    return @as(f32, @floatFromInt(int));
}

/// Convert a float (f32) to an integer (i32)
pub fn fti(float: f32) i32 {
    return @as(i32, @intFromFloat(float));
}

/// Convert a float (f32) to an unsigned integer (u32)
pub fn ftu(float: f32) u32 {
    return @as(u32, @intFromFloat(float));
}

/// Convert a f64 to a f32
pub fn ftf(float: f64) f32 {
    return @as(f32, @floatCast(float));
}

/// Possible movements
pub const MOVE = enum {
    UP,
    DOWN,
    LEFT,
    RIGHT,
};

/// Check for a key press
pub fn keyPressed(key: MOVE) bool {
    switch (key) {
        .UP => return rl.isKeyDown(rl.KeyboardKey.w) or rl.isKeyDown(rl.KeyboardKey.up),
        .DOWN => return rl.isKeyDown(rl.KeyboardKey.s) or rl.isKeyDown(rl.KeyboardKey.down),
        .LEFT => return rl.isKeyDown(rl.KeyboardKey.a) or rl.isKeyDown(rl.KeyboardKey.left),
        .RIGHT => return rl.isKeyDown(rl.KeyboardKey.d) or rl.isKeyDown(rl.KeyboardKey.right),
    }
}
