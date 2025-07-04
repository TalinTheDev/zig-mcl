// Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
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
    speed: f32 = 30,
    angularSpeed: f32 = 80,
    realSpeed: f32 = 30,
    realAngularSpeed: f32 = 80,
    viewDistance: f32 = 500,
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
        // for (self.castRays()) |ray| {
        //     rl.drawLine(lib.fti(ray.start.x), lib.fti(ray.start.y), lib.fti(ray.end.x), lib.fti(ray.end.y), rl.Color.red);
        // }
    }

    /// Returns an array of four floats representing the closest distance
    /// detected by each ray cast from each direction of the robot
    // Just trust the math bro, idek
    pub fn distanceToClosestSide(self: *Robot, exact: bool, randEnv: *zprob.RandomEnvironment, stdev: f32) [4]f32 {
        const rays = self.castRays();
        var dists: [rays.len]f32 = undefined;
        for (rays, 0..) |ray, i| {
            var closestDist: f32 = std.math.floatMax(f32);
            for (lib.walls) |wallToCheck| {
                const d = (ray.start.x - ray.end.x) * (wallToCheck.start.y - wallToCheck.end.y) - (ray.start.y - ray.end.y) * (wallToCheck.start.x - wallToCheck.end.x);

                if (d == 0) {
                    continue;
                }
                const t = ((ray.start.x - wallToCheck.start.x) * (wallToCheck.start.y - wallToCheck.end.y) - (ray.start.y - wallToCheck.start.y) * (wallToCheck.start.x - wallToCheck.end.x)) / d;

                // const u = ((ray.start.x - wallToCheck.start.x) * (ray.start.y - ray.end.y) - (ray.start.y - wallToCheck.start.y) * (ray.start.x - ray.end.y)) / d;

                const hitPoint = rl.Vector2{
                    .x = ray.start.x + t * (ray.end.x - ray.start.x),
                    .y = ray.start.y + t * (ray.end.y - ray.start.y),
                };

                const dist = rm.vector2Length(rm.vector2Subtract(hitPoint, ray.start));

                if (dist < closestDist) {
                    closestDist = dist;
                    // rl.drawLine(lib.fti(ray.start.x), lib.fti(ray.start.y), lib.fti(hitPoint.x), lib.fti(hitPoint.y), rl.Color.red);
                }
            }

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

            // delta position = speed * delta time (time between frames)
            self.pos.x += self.realSpeed * @cos(std.math.degreesToRadians(self.heading)) * rl.getFrameTime();
            var dirX: f32 = std.math.sign(prevPosX - self.pos.x);

            // Check for collisions and back out horizontally if colliding
            while (self.checkCollision()) {
                if (dirX == 0.0) dirX = 1.0;
                self.pos.x += dirX;
            }

            self.pos.y += self.realSpeed * @sin(std.math.degreesToRadians(self.heading)) * rl.getFrameTime();
            var dirY: f32 = std.math.sign(prevPosY - self.pos.y);

            // Check for collisions and back out vertically if colliding
            while (self.checkCollision()) {
                if (dirY == 0.0) dirY = 1.0;
                self.pos.y += dirY;
            }

            self.heading += self.realAngularSpeed * rl.getFrameTime();
            self.updateSensorLoc();
        }
    }

    /// Check wall collisions
    pub fn checkCollision(self: *Robot) bool {
        for (0..lib.walls.len) |i| {
            const wallToCheck = lib.wall.walls[i];

            if (rl.checkCollisionCircleLine(self.pos, self.radius, wallToCheck.start, wallToCheck.end)) {
                return true;
            }
        }
        return false;
    }
};
