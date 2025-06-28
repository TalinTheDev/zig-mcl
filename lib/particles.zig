// Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
//! Contains the logic for the simulation's particles

// Imports
const rl = @import("raylib");
const Robot = @import("robot.zig");
const std = @import("std");
const utils = @import("utils.zig");
const Field = @import("field.zig");

/// Represents a particle
pub const Particle = struct {
    robot: Robot.Robot,
    id: usize,
};

/// Returns an array of particles with their position being randomly generated
/// within the field's boundaries
pub fn initParticles(comptime count: i32, rand: *std.Random) [count]Particle {
    var particles = [_]Particle{undefined} ** count;
    for (0..count) |i| {
        var robot = Robot.Robot{
            .center = rl.Vector2{
                .x = utils.itf(rand.intRangeAtMost(i32, Field.field.x + 15, Field.field.x + Field.field.width - 15)),
                .y = utils.itf(rand.intRangeAtMost(i32, Field.field.x + 15, Field.field.x + Field.field.width - 15)),
            },
            .radius = 10,
            .color = rl.Color.green,
        };

        _ = &robot;
        particles[i] = Particle{
            .robot = robot,
            .id = i,
        };
    }
    return particles;
}

pub fn updateParticles(particles: []Particle) void {
    std.debug.print("\n\n================================================\n\n", .{});
    for (particles) |*particle| {
        std.debug.print("#{} - ({d}, {d}) -> ", .{
            particle.id,
            particle.robot.center.x,
            particle.robot.center.y,
        });
        particle.robot.update();
        std.debug.print("({d}, {d})\n", .{
            particle.robot.center.x,
            particle.robot.center.y,
        });
    }
}
