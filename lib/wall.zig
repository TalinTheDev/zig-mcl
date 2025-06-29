// Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
//! Contains the logic for the simulation's field

// Imports
const rl = @import("raylib");
const V2 = rl.Vector2;

/// Represents a singular wall
pub const Wall = struct {
    start: V2,
    end: V2,
    width: f32 = 5.0,
};

/// The walls on the field
var wallList = [_]Wall{
    // Field Boundary Walls
    Wall{
        .start = V2{ .x = 50, .y = 50 },
        .end = V2{ .x = 650, .y = 50 },
    },
    Wall{
        .start = V2{ .x = 650, .y = 50 },
        .end = V2{ .x = 650, .y = 650 },
    },
    Wall{
        .start = V2{ .x = 650, .y = 650 },
        .end = V2{ .x = 50, .y = 650 },
    },
    Wall{
        .start = V2{ .x = 50, .y = 650 },
        .end = V2{ .x = 50, .y = 50 },
    },

    // Obstacles
    Wall{
        .start = V2{ .x = 100, .y = 100 },
        .end = V2{ .x = 100, .y = 500 },
    },
};

pub const walls: []Wall = wallList[0..wallList.len];
