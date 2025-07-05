// Copyright 2025 Talin Sharma and Alex Oh. Subject to the Apache-2.0 license.
//! Contains the logic for the simulation's robot

// Imports
const std = @import("std");
const rl = @import("raylib");
const rm = rl.math;
const wall = @import("wall.zig");
const lib = @import("root.zig");
const zprob = @import("zprob");

/// Robot
pub const Robot = struct {
    pos: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 },
    sPos: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 },
    radius: f32 = 10,
    heading: f32 = -90,
    speed: f32 = 100,
    angularSpeed: f32 = 150,
    realSpeed: f32 = 100,
    realAngularSpeed: f32 = 150,
    viewDistance: f32 = 1000,
    color: rl.Color = rl.Color.orange,
    isParticle: bool = false,
    isEstimate: bool = false,

    pub fn init(startPos: rl.Vector2, heading: f32, color: rl.Color, isParticle: bool) Robot {
        return Robot{
            .pos = startPos,
            .heading = heading,
            .color = color,
            .isParticle = isParticle,
        };
    }

    pub fn setPos(self: *Robot, x: f32, y: f32) void {
        self.pos = rl.Vector2{
            .x = x,
            .y = y,
        };
    }

    pub fn draw(self: *Robot) void {
        rl.drawCircleV(self.pos, self.radius, self.color);
        rl.drawCircleV(self.sPos, self.radius / 4, rl.Color.black);
    }

    /// Returns an array of four floats representing the closest distance
    /// detected by each ray cast from each direction of the robot
    // Just trust the math bro, idek
    pub fn distanceToClosestSide(self: *Robot, exact: bool, randEnv: *zprob.RandomEnvironment, stdev: f32) [4]f32 {
        const rays = self.castRays();
        var dists: [rays.len]f32 = undefined;
        for (rays, 0..) |ray, i| {
            var closestDist: f32 = std.math.floatMax(f32);
            var closestHitPoint: ?rl.Vector2 = null;
            for (lib.walls) |w| {
                const d1 = ray.end.subtract(ray.start); // Vector for the ray
                const d2 = w.end.subtract(w.start); // Vector for the wall
                const p = w.start.subtract(ray.start); // Vector from ray start point to wall start point

                const denom = rm.vector2CrossProduct(d1, d2); // Denominator for t and u parametric variables

                // Check if lines are parallel
                if (@abs(denom) < 1) {
                    continue;
                }

                // Calculate parametric variables for intersection point
                // t for the ray, u for the wall, with t,u = 0 and t,u = 1 representing the start and end points of each segment
                const t = rm.vector2CrossProduct(p, d2) / denom;
                const u = rm.vector2CrossProduct(p, d1) / denom;

                // Make sure intersection point is on both line segments
                if (t < 0.0 or t > 1.0 or u < 0.0 or u > 1.0) {
                    continue;
                }

                // Get intersection point relative to ray start
                const relativeHitPoint = d1.scale(t);
                const dist = relativeHitPoint.length(); // Distance from ray start to hit point

                // Get absolute intersection point
                const hitPoint = ray.start.add(d1.scale(t));

                // Keep track of closest hit point
                if (dist < closestDist) {
                    closestDist = dist;
                    closestHitPoint = hitPoint;
                }
            }

            // For debugging purposes
            // if (closestHitPoint) |closestHit| {
            //     if (!self.isParticle) {
            //         rl.drawLine(lib.fti(ray.start.x), lib.fti(ray.start.y), lib.fti(closestHit.x), lib.fti(closestHit.y), rl.Color.red);
            //     }
            // }

            if (!exact) {
                // Use a normal distribution to vary the sensor reading
                closestDist = lib.ftf(randEnv.rNormal(closestDist, stdev) catch {
                    std.debug.print("dist: {d}, stdev: {d}", .{ closestDist, stdev });
                    return [4]f32{ 0, 0, 0, 0 };
                });
            }

            dists[i] = closestDist;
        }

        return dists;
    }

    pub const Ray = struct { start: rl.Vector2, end: rl.Vector2 };
    pub fn castRays(self: *Robot) [4]Ray {
        // -90 Deg Ray
        const rayStart90 = rl.Vector2{
            .x = self.sPos.x + ((self.radius / 4) * @cos(std.math.degreesToRadians(self.heading))),
            .y = self.sPos.y + ((self.radius / 4) * @sin(std.math.degreesToRadians(self.heading))),
        };
        const rayEnd90 = rl.Vector2{
            .x = rayStart90.x + self.viewDistance * @cos(std.math.degreesToRadians(self.heading)),
            .y = rayStart90.y + self.viewDistance * @sin(std.math.degreesToRadians(self.heading)),
        };

        // -270 Deg Ray
        const rayStart270 = rl.Vector2{
            .x = self.sPos.x + ((self.radius / 4) * @cos(std.math.degreesToRadians(self.heading - 180))),
            .y = self.sPos.y + ((self.radius / 4) * @sin(std.math.degreesToRadians(self.heading - 180))),
        };
        const rayEnd270 = rl.Vector2{
            .x = rayStart270.x + self.viewDistance * @cos(std.math.degreesToRadians(self.heading - 180)),
            .y = rayStart270.y + self.viewDistance * @sin(std.math.degreesToRadians(self.heading - 180)),
        };

        // 0 Deg Ray
        const rayStart0 = rl.Vector2{
            .x = self.sPos.x + ((self.radius / 4) * @cos(std.math.degreesToRadians(self.heading + 90))),
            .y = self.sPos.y + ((self.radius / 4) * @sin(std.math.degreesToRadians(self.heading + 90))),
        };
        const rayEnd0 = rl.Vector2{
            .x = rayStart0.x + self.viewDistance * @cos(std.math.degreesToRadians(self.heading + 90)),
            .y = rayStart0.y + self.viewDistance * @sin(std.math.degreesToRadians(self.heading + 90)),
        };

        // -180 Deg Ray
        const rayStart180 = rl.Vector2{
            .x = self.sPos.x + ((self.radius / 4) * @cos(std.math.degreesToRadians(self.heading - 90))),
            .y = self.sPos.y + ((self.radius / 4) * @sin(std.math.degreesToRadians(self.heading - 90))),
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

    /// Updates the position of the sensor inside the robot
    pub fn updateSensorLoc(self: *Robot) void {
        self.sPos = rl.Vector2{
            .x = self.pos.x + ((self.radius / 2) * @cos(std.math.degreesToRadians(self.heading))),
            .y = self.pos.y + ((self.radius / 2) * @sin(std.math.degreesToRadians(self.heading))),
        };
    }

    /// Handles movement for a robot
    pub fn update(self: *Robot, exact: bool, randEnv: *zprob.RandomEnvironment, speedStDev: f32, angularSpeedStDev: f32, actualSpeed: f32, actualAngularSpeed: f32) void {
        if (!self.isEstimate) {
            // Generate randomness using normal distribution
            const noise: f32 = if (!exact) lib.ftf(randEnv.rNormal(0, speedStDev) catch {
                std.debug.print("invalid speed noise", .{});
                return;
            }) else 0.0;
            const noiseA: f32 = if (!exact) lib.ftf(randEnv.rNormal(0, angularSpeedStDev) catch {
                std.debug.print("invalid angular noise", .{});
                return;
            }) else 0.0;

            if (self.isParticle) {
                // Set particle's speed to the actual robot's speed and add noise
                self.speed = actualSpeed;
                self.angularSpeed = actualAngularSpeed;
                self.realSpeed = (self.speed + noise);
                self.realAngularSpeed = (self.angularSpeed + noiseA);

                if (self.speed == 0.0) {
                    self.realSpeed = 0.0;
                }

                if (self.angularSpeed == 0.0) {
                    self.realAngularSpeed = 0;
                }
            } else {
                // Get keyboard input and assign to joystick value
                const joystickV = @as(f32, @floatFromInt(@intFromBool(rl.isKeyDown(rl.KeyboardKey.w) or rl.isKeyDown(rl.KeyboardKey.up)))) -
                    @as(f32, @floatFromInt(@intFromBool(rl.isKeyDown(rl.KeyboardKey.s) or rl.isKeyDown(rl.KeyboardKey.down))));
                const joystickH = @as(f32, @floatFromInt(@intFromBool(rl.isKeyDown(rl.KeyboardKey.d) or rl.isKeyDown(rl.KeyboardKey.right)))) -
                    @as(f32, @floatFromInt(@intFromBool(rl.isKeyDown(rl.KeyboardKey.a) or rl.isKeyDown(rl.KeyboardKey.left))));

                self.realSpeed = (self.speed + noise) * joystickV;
                self.realAngularSpeed = (self.angularSpeed + noiseA) * joystickH;
            }

            const prevPosX = self.pos.x;
            const prevPosY = self.pos.y;

            const deltaX = self.realSpeed * @cos(std.math.degreesToRadians(self.heading)) * rl.getFrameTime();
            const deltaY = self.realSpeed * @sin(std.math.degreesToRadians(self.heading)) * rl.getFrameTime();
            const dirX: f32 = std.math.sign(deltaX);
            const dirY: f32 = std.math.sign(deltaY);

            // delta position = speed * delta time (time between frames)
            while (@abs(self.pos.x - prevPosX) < @abs(deltaX)) {
                self.pos.x += dirX * 0.1;
                if (self.checkCollision()) {
                    self.pos.x -= dirX * 0.1;
                    break;
                }
            }

            // // Check for collisions and back out horizontally if colliding
            // while (self.checkCollision()) {
            //     if (dirX == 0.0) dirX = 1.0;
            //     self.pos.x += dirX;
            // }

            // delta position = speed * delta time (time between frames)
            while (@abs(self.pos.y - prevPosY) < @abs(deltaY)) {
                self.pos.y += dirY * 0.1;
                if (self.checkCollision()) {
                    self.pos.y -= dirY * 0.1;
                    break;
                }
            }

            // // Check for collisions and back out vertically if colliding
            // while (self.checkCollision()) {
            //     if (dirY == 0.0) dirY = 1.0;
            //     self.pos.y += dirY;
            // }

            self.heading += self.realAngularSpeed * rl.getFrameTime();
            self.updateSensorLoc();
        }
    }

    /// Check wall collisions
    pub fn checkCollision(self: *Robot) bool {
        for (0..lib.walls.len) |i| {
            const w = lib.wall.walls[i];

            if (rl.checkCollisionCircleLine(self.pos, self.radius, w.start, w.end)) {
                return true;
            }
        }
        return false;
    }
};
