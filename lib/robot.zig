// Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
//! Contains the logic for the simulation's robot

// Imports
const std = @import("std");
const rl = @import("raylib");
const Field = @import("field.zig");
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
        const side = Field.walls[sideNum];

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
        if (lib.checkFieldCollision(self, 0) or lib.field.walls[0].start.y + 15 > self.center.y) {
            self.center.y = lib.field.walls[0].start.y + 15;
        }
        if (lib.checkFieldCollision(self, 1) or lib.field.walls[1].start.x - 15 < self.center.x) {
            self.center.x = lib.field.walls[1].start.x - 15;
        }
        if (lib.checkFieldCollision(self, 2) or lib.field.walls[2].start.y - 15 < self.center.y) {
            self.center.y = lib.field.walls[2].start.y - 15;
        }
        if (lib.checkFieldCollision(self, 3) or lib.field.walls[3].start.x + 15 > self.center.x) {
            self.center.x = lib.field.walls[3].start.x + 15;
        }
    }
};
