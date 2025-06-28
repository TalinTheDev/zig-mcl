// Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
//! Contains the logic for the simulation's robot

// Imports
const std = @import("std");
const rl = @import("raylib");
const Field = @import("field.zig");
const lib = @import("root.zig");

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

    pub fn update(self: *Robot) void {
        var moved = false;
        if (lib.keyPressed(lib.MOVE.UP)) {
            self.center.y -= 10;
            moved = true;
        }
        if (lib.keyPressed(lib.MOVE.DOWN)) {
            self.center.y += 10;
            moved = true;
        }
        if (lib.keyPressed(lib.MOVE.LEFT)) {
            self.center.x -= 10;
            moved = true;
        }
        if (lib.keyPressed(lib.MOVE.RIGHT)) {
            self.center.x += 10;
            moved = true;
        }

        // Check field wall collisions
        if (lib.checkFieldCollision(self, 0)) {
            self.center.y = lib.field.walls[0].start.y + 15;
        }
        if (lib.checkFieldCollision(self, 1)) {
            self.center.x = lib.field.walls[1].start.x - 15;
        }
        if (lib.checkFieldCollision(self, 2)) {
            self.center.y = lib.field.walls[2].start.y - 15;
        }
        if (lib.checkFieldCollision(self, 3)) {
            self.center.x = lib.field.walls[3].start.x + 15;
        }
    }
};
