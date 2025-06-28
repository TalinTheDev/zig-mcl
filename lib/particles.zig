// Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
//! Contains the logic for the simulation's particles

// Imports
const rl = @import("raylib");
const Robot = @import("robot.zig");

/// Represents a particle
pub const Particle = struct {
    robot: Robot.Robot,
    id: usize,
};

/// Returns an array of particles
pub fn initParticles(comptime count: i32) [count]Particle {
    var particles = [_]Particle{undefined} ** count;
    for (0..count) |i| {
        particles[i] = Particle{
            .robot = Robot.Robot{
                .center = rl.Vector2{
                    .x = 50.0 + @as(f32, @floatFromInt(i)),
                    .y = 50.0 + @as(f32, @floatFromInt(i)),
                },
                .radius = 10,
                .color = rl.Color.green,
            },
            .id = i,
        };
    }
    return particles;
}
