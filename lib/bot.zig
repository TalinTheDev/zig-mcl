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

    /// Returns an array of four floats representing the closest distance
    /// detected by each ray cast from each direction of the robot
    // Just trust the math bro, idek
    pub fn distanceToClosestSide(self: *Robot, rand: zprob.Uniform(f32), exact: bool) [4]f32 {
        const diff = if (!exact) rand.sample(-4, 4) else 0;

        const rays = self.castRays();
        var dists: [rays.len]f32 = undefined;
        for (rays, 0..) |ray, i| {
            var closestDist: f32 = std.math.floatMin(f32);
            for (lib.walls) |wallToCheck| {
                const d = (ray.start.x - ray.end.x) * (wallToCheck.start.y - wallToCheck.end.y) - (ray.start.y - ray.end.y) * (wallToCheck.start.x - wallToCheck.end.x);

                if (d == 0) {
                    continue;
                }
                const t = ((ray.start.x - wallToCheck.start.x) * (wallToCheck.start.y - wallToCheck.end.y) - (ray.start.y - wallToCheck.start.y) * (wallToCheck.start.x - wallToCheck.end.x)) / d;

                // const u = ((ray.start.x - wallToCheck.start.x) * (ray.start.y - ray.end.y) - (ray.start.y - wallToCheck.start.y) * (ray.start.x - ray.end.y)) / d;

                const x = (ray.start.x + t * (ray.end.x - ray.start.x));
                const y = (ray.start.y + t * (ray.end.y - ray.start.y));

                const dist = std.math.sqrt((std.math.pow(f32, (x - ray.start.x), 2) + std.math.pow(f32, (y - ray.start.y), 2))) + diff;
                if (dist < closestDist) {
                    closestDist = dist;
                }
            }
            dists[i] = closestDist;
        }
        return dists;
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
    pub fn updateKidnap(self: *Robot, rand: zprob.Uniform(f32)) void {
        if (rl.isKeyPressed(rl.KeyboardKey.k)) {
            const rangeMin = wall.walls[0].start.x + 12.5;
            const rangeMax = wall.walls[0].end.x - 12.5;
            const posX = rand.sample(rangeMin, rangeMax);
            const posY = rand.sample(rangeMin, rangeMax);

            self.center = rl.Vector2{
                .x = posX,
                .y = posY,
            };

            while (!self.checkCollision()) {
                self.center = rl.Vector2{
                    .x = posX,
                    .y = posY,
                };
            }
        }
    }
    /// Updates the position of the small circle inside the robot
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
