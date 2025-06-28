// Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
//! Contains the logic for the simulation's field

// Imports
const rl = @import("raylib");

/// Represents a singular field wall
pub const FieldWall = struct {
    start: rl.Vector2,
    end: rl.Vector2,
};

/// Define the field & its boundaries
pub const field = rl.Rectangle{
    .x = 50,
    .y = 50,
    .width = 600,
    .height = 600,
};

/// Define the 4 walls of the field
pub const walls: [4]FieldWall = .{
    FieldWall{
        .start = rl.Vector2{ .x = 50, .y = 50 },
        .end = rl.Vector2{ .x = 650, .y = 50 },
    },
    FieldWall{
        .start = rl.Vector2{ .x = 650, .y = 50 },
        .end = rl.Vector2{ .x = 650, .y = 650 },
    },
    FieldWall{
        .start = rl.Vector2{ .x = 650, .y = 650 },
        .end = rl.Vector2{ .x = 50, .y = 650 },
    },
    FieldWall{
        .start = rl.Vector2{ .x = 50, .y = 650 },
        .end = rl.Vector2{ .x = 50, .y = 50 },
    },
};
