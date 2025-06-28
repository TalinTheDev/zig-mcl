// Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
//! Contains the logic for the simulation's robot

// Imports
const rl = @import("raylib");

/// Robot
pub const Robot = struct {
    center: rl.Vector2,
    radius: f32 = 10,
    color: rl.Color = rl.Color.orange,
};
