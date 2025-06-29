// Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
//! Contains the logic for the simulation's particles

// Imports
const rl = @import("raylib");
const Robot = @import("robot.zig");
const std = @import("std");
const utils = @import("utils.zig");
const Field = @import("field.zig");
const zprob = @import("zprob");

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
        particles[i] = Particle{
            .robot = Robot.Robot{
                .center = rl.Vector2{
                    .x = utils.itf(rand.intRangeAtMost(i32, Field.field.x + 15, Field.field.x + Field.field.width - 15)),
                    .y = utils.itf(rand.intRangeAtMost(i32, Field.field.x + 15, Field.field.x + Field.field.width - 15)),
                },
                .radius = 10,
                .color = rl.Color.green,
            },
            .id = i,
        };
    }
    return particles;
}

/// Updates the particles (random movement)
pub fn updateParticles(particles: []Particle, rand: *std.Random) void {
    for (particles) |*particle| {
        particle.robot.update(rand, false);
    }
}

const sdev = 0.4;
const pi2 = std.math.pow(f32, std.math.pi, 2);

/// Re-samples the particles and moves them accordingly
pub fn resample(particles: []Particle, comptime PARTICLE_COUNT: i32, normal: zprob.Normal(f32), robot: *Robot.Robot) void {
    var probabilities = [_]f32{0.00} ** PARTICLE_COUNT;

    const rdT = robot.distanceFromSide(0);
    const rdR = robot.distanceFromSide(1);
    const rdB = robot.distanceFromSide(2);
    const rdL = robot.distanceFromSide(3);

    for (particles, 0..) |*particle, i| {
        const dT = particle.robot.distanceFromSide(0);
        const dR = particle.robot.distanceFromSide(1);
        const dB = particle.robot.distanceFromSide(2);
        const dL = particle.robot.distanceFromSide(3);

        const r = normal.pdf(rdT, dT, 0.2) catch 0.0;
        _ = r;
        const probT = normal.pdf(rdT, dT, sdev) catch 0.0;
        const probR = normal.pdf(rdR, dR, sdev) catch 0.0;
        const probB = normal.pdf(rdB, dB, sdev) catch 0.0;
        const probL = normal.pdf(rdL, dL, sdev) catch 0.0;
        probabilities[i] = (probT + probR + probB + probL) / 4 * 100;
        std.debug.print("Particle #{} has probability {d:.4}% from rdT = {d}, dT = {d}\n", .{ particle.id, probabilities[i], rdT, dT });
    }
}
