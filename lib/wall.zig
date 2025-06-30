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
// Ensure that the end vectors are greater than the start in both x and y.
// Otherwise, wall collisions don't properly work
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

    // // Obstacles
    //
    // // Center
    // Wall{
    //     .start = V2{ .x = 300, .y = 200 },
    //     .end = V2{ .x = 500, .y = 200 },
    // },
    // Wall{
    //     .start = V2{ .x = 500, .y = 200 },
    //     .end = V2{ .x = 500, .y = 400 },
    // },
    // Wall{
    //     .start = V2{ .x = 200, .y = 500 },
    //     .end = V2{ .x = 400, .y = 500 },
    // },
    // Wall{
    //     .start = V2{ .x = 200, .y = 300 },
    //     .end = V2{ .x = 200, .y = 500 },
    // },
    //
    // // Top Left
    // Wall{
    //     .start = V2{ .x = 100, .y = 100 },
    //     .end = V2{ .x = 100, .y = 300 },
    // },
    // Wall{
    //     .start = V2{ .x = 100, .y = 300 },
    //     .end = V2{ .x = 150, .y = 300 },
    // },
    // Wall{
    //     .start = V2{ .x = 150, .y = 300 },
    //     .end = V2{ .x = 150, .y = 400 },
    // },
    //
    // // Bottom Right
    // Wall{
    //     .start = V2{ .x = 400, .y = 550 },
    //     .end = V2{ .x = 450, .y = 550 },
    // },
    // Wall{
    //     .start = V2{ .x = 450, .y = 400 },
    //     .end = V2{ .x = 450, .y = 550 },
    // },
    // Wall{
    //     .start = V2{ .x = 450, .y = 400 },
    //     .end = V2{ .x = 550, .y = 400 },
    // },
    // Wall{
    //     .start = V2{ .x = 550, .y = 350 },
    //     .end = V2{ .x = 550, .y = 400 },
    // },

    // VEX Field
    Wall{
        .start = V2{ .x = 225, .y = 125 },
        .end = V2{ .x = 475, .y = 125 },
    },
    Wall{
        .start = V2{ .x = 225, .y = 575 },
        .end = V2{ .x = 475, .y = 575 },
    },
    Wall{
        .start = V2{ .x = 300, .y = 300 },
        .end = V2{ .x = 390, .y = 390 },
    },
    Wall{
        .start = V2{ .x = 390, .y = 300 },
        .end = V2{ .x = 300, .y = 390 },
    },
};

pub const walls: []Wall = wallList[0..wallList.len];
