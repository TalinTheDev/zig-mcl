// Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
//! Contains the logic for the simulation's robot

// Imports
const std = @import("std");
const rl = @import("raylib");
const Field = @import("field.zig");

/// Robot
pub const Robot = struct {
    center: rl.Vector2,
    radius: f32 = 10,
    color: rl.Color = rl.Color.orange,

    pub fn distanceFromSide(self: *Robot, sideNum: usize) f32 {
        // Adding/Subtracting 15 to account for robot radius & wall thickness
        var radius: f32 = 15.0;
        const side = Field.walls[sideNum];

        // if the wall is vertical -> return horizontal distance;
        // else -> return vertical distance;
        if (side.end.y != side.start.y) {
            // if the robot is on the right of the wall -> subtract the radius
            if (self.center.x > side.start.x) {
                radius = -15.0;
            }
            return self.center.x - side.start.x + radius;
        }

        if (self.center.y > side.start.y) {
            radius = -15.0;
        }
        return self.center.y - side.start.y + radius;
    }
};
