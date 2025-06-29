// Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
//! Contains the logic for the simulation's robot

// Imports
const std = @import("std");
const rl = @import("raylib");
const wall = @import("wall.zig");
const lib = @import("root.zig");
const zprob = @import("zprob");

/// Robot
pub const Robot = struct {
    center: rl.Vector2,
    radius: f32 = 10,
    color: rl.Color = rl.Color.orange,

    pub fn distanceFromSide(self: *Robot, sideNum: usize, rand: zprob.Uniform(f32), exact: bool) f32 {
        const diff = if (!exact) rand.sample(-2, 2) else 1;
        // Adding/Subtracting 15 to account for robot radius & wall thickness
        var radius: f32 = 15.0;
        const side = wall.walls[sideNum];

        // if the wall is vertical -> return horizontal distance;
        // else -> return vertical distance;
        if (side.end.y != side.start.y) {
            // if the robot is on the right of the wall -> subtract the radius
            if (self.center.x > side.start.x) {
                radius = -15.0;
            }
            return (self.center.x - side.start.x) * diff + radius;
        }

        if (self.center.y > side.start.y) {
            radius = -15.0;
        }
        return (self.center.y - side.start.y) * diff + radius;
    }

    /// Handles movement for a robot
    pub fn update(self: *Robot, rand: *std.Random, exact: bool) void {
        const diff = if (!exact) lib.itf(rand.intRangeAtMost(i32, 0, 4)) else 2;
        const preMoveY = self.center.y;
        const preMoveX = self.center.x;
        if (lib.keyPressed(lib.MOVE.UP)) {
            self.center.y -= diff;
        }
        if (lib.keyPressed(lib.MOVE.DOWN)) {
            self.center.y += diff;
        }
        if (lib.keyPressed(lib.MOVE.LEFT)) {
            self.center.x -= diff;
        }
        if (lib.keyPressed(lib.MOVE.RIGHT)) {
            self.center.x += diff;
        }

        // Check field wall collisions
        for (0..lib.walls.len) |i| {
            const rightX = preMoveX > lib.wall.walls[i].start.x;
            const aboveY = preMoveY > lib.wall.walls[i].start.y;
            if (lib.checkHorizontalCollision(self, i, rightX)) {
                self.center.x = lib.wall.walls[i].start.x + 12.5;
                if (rightX) {
                    self.center.x = lib.wall.walls[i].start.x + 12.5;
                } else {
                    self.center.x = lib.wall.walls[i].start.x - 12.5;
                }
            }
            if (lib.checkVerticalCollision(self, i, aboveY)) {
                if (aboveY) {
                    self.center.y = lib.wall.walls[i].start.y + 12.5;
                } else {
                    self.center.y = lib.wall.walls[i].start.y - 12.5;
                }
            }
        }
    }
};
