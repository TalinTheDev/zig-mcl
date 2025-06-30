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
    sCenter: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 },
    radius: f32 = 10,
    heading: f32 = -90,
    viewDistance: f32 = 500,
    color: rl.Color = rl.Color.orange,

    pub fn draw(self: *Robot) void {
        rl.drawCircleV(self.center, self.radius, self.color);
        rl.drawCircleV(self.sCenter, self.radius / 4, rl.Color.black);
        _ = self.castRays();
    }

    pub fn distanceFromSide(self: *Robot, sideNum: usize, rand: zprob.Uniform(f32), exact: bool) f32 {
        _ = .{ self, sideNum, rand, exact };
        return 0.0;
        // const diff = if (!exact) rand.sample(-2, 2) else 1;
        // // Adding/Subtracting 15 to account for robot radius & wall thickness
        // var radius: f32 = 12.5;
        // const side = wall.walls[sideNum];
        //
        // // if the wall is vertical -> return horizontal distance;
        // // else -> return vertical distance;
        // if (side.end.y != side.start.y) {
        //     // if the robot is on the right of the wall -> subtract the radius
        //     if (self.center.x > side.start.x) {
        //         radius *= -1;
        //     }
        //     return (self.center.x - side.start.x) * diff + radius;
        // }
        //
        // if (self.center.y > side.start.y) {
        //     radius *= -1;
        // }
        // return (self.center.y - side.start.y) * diff + radius;
    }

    pub const Ray = struct { start: rl.Vector2, end: rl.Vector2 };
    pub fn castRays(self: *Robot) [4]Ray {
        // -90 Deg Ray
        const rayStart90 = rl.Vector2{
            .x = self.sCenter.x + ((self.radius / 4) * @cos(std.math.degreesToRadians(self.heading))),
            .y = self.sCenter.y + ((self.radius / 4) * @sin(std.math.degreesToRadians(self.heading))),
        };
        const rayEnd90 = rl.Vector2{
            .x = rayStart90.x + self.viewDistance * @cos(std.math.degreesToRadians(self.heading)),
            .y = rayStart90.y + self.viewDistance * @sin(std.math.degreesToRadians(self.heading)),
        };

        // -270 Deg Ray
        const rayStart270 = rl.Vector2{
            .x = self.sCenter.x + ((self.radius / 4) * @cos(std.math.degreesToRadians(self.heading - 180))),
            .y = self.sCenter.y + ((self.radius / 4) * @sin(std.math.degreesToRadians(self.heading - 180))),
        };
        const rayEnd270 = rl.Vector2{
            .x = rayStart270.x + self.viewDistance * @cos(std.math.degreesToRadians(self.heading - 180)),
            .y = rayStart270.y + self.viewDistance * @sin(std.math.degreesToRadians(self.heading - 180)),
        };

        // 0 Deg Ray
        const rayStart0 = rl.Vector2{
            .x = self.sCenter.x + ((self.radius / 4) * @cos(std.math.degreesToRadians(self.heading + 90))),
            .y = self.sCenter.y + ((self.radius / 4) * @sin(std.math.degreesToRadians(self.heading + 90))),
        };
        const rayEnd0 = rl.Vector2{
            .x = rayStart0.x + self.viewDistance * @cos(std.math.degreesToRadians(self.heading + 90)),
            .y = rayStart0.y + self.viewDistance * @sin(std.math.degreesToRadians(self.heading + 90)),
        };

        // -180 Deg Ray
        const rayStart180 = rl.Vector2{
            .x = self.sCenter.x + ((self.radius / 4) * @cos(std.math.degreesToRadians(self.heading - 90))),
            .y = self.sCenter.y + ((self.radius / 4) * @sin(std.math.degreesToRadians(self.heading - 90))),
        };
        const rayEnd180 = rl.Vector2{
            .x = rayStart180.x + self.viewDistance * @cos(std.math.degreesToRadians(self.heading - 90)),
            .y = rayStart180.y + self.viewDistance * @sin(std.math.degreesToRadians(self.heading - 90)),
        };
        return [_]Ray{
            Ray{ .start = rayStart90, .end = rayEnd90 },
            Ray{ .start = rayStart270, .end = rayEnd270 },
            Ray{ .start = rayStart0, .end = rayEnd0 },
            Ray{ .start = rayStart180, .end = rayEnd180 },
        };
    }

    pub fn updateAfterRotation(self: *Robot) void {
        self.sCenter = rl.Vector2{
            .x = self.center.x + ((self.radius / 2) * @cos(std.math.degreesToRadians(self.heading))),
            .y = self.center.y + ((self.radius / 2) * @sin(std.math.degreesToRadians(self.heading))),
        };
    }

    /// Handles movement for a robot
    pub fn update(self: *Robot, rand: *std.Random, exact: bool) void {
        const diff = if (!exact) lib.itf(rand.intRangeAtMost(i32, 0, 4)) else 2;
        const diffA = if (!exact) lib.itf(rand.intRangeAtMost(i32, 0, 10)) else 5;
        const preMoveY = self.center.y;
        const preMoveX = self.center.x;
        if (rl.isKeyDown(rl.KeyboardKey.w)) {
            self.center.y -= diff;
        }
        if (rl.isKeyDown(rl.KeyboardKey.s)) {
            self.center.y += diff;
        }
        if (rl.isKeyDown(rl.KeyboardKey.a)) {
            self.center.x -= diff;
        }
        if (rl.isKeyDown(rl.KeyboardKey.d)) {
            self.center.x += diff;
        }

        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            self.heading -= diffA;
        }
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            self.heading += diffA;
        }
        self.updateAfterRotation();
        if (!self.checkCollision()) {
            self.center.x = preMoveX;
            self.center.y = preMoveY;
        }
        self.updateAfterRotation();
    }

    /// Check wall collisions
    pub fn checkCollision(self: *Robot) bool {
        for (0..lib.walls.len) |i| {
            const wallToCheck = lib.wall.walls[i];

            if (rl.checkCollisionCircleLine(self.center, self.radius, wallToCheck.start, wallToCheck.end)) {
                return false;
            }
        }
        return true;
    }
};
