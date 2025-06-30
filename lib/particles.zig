// Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
//! Contains the logic for the simulation's particles

// Imports
const rl = @import("raylib");
const bot = @import("bot.zig");
const std = @import("std");
const utils = @import("utils.zig");
const wall = @import("wall.zig");
const zprob = @import("zprob");
const lib = @import("root.zig");

/// Represents a particle
pub const Particle = struct {
    robot: bot.Robot,
    id: usize,
};

/// Returns an array of particles with their position being randomly generated
/// within the field's boundaries
pub fn initParticles(comptime count: i32, rand: *std.Random) [count]Particle {
    var particles = [_]Particle{undefined} ** count;
    const rangeMin = lib.fti(wall.walls[0].start.x + 12.5);
    const rangeMax = lib.fti(wall.walls[0].end.x - 12.5);
    for (0..count) |i| {
        var particle = Particle{
            .robot = bot.Robot{
                .center = rl.Vector2{
                    .x = utils.itf(rand.intRangeAtMost(i32, rangeMin, rangeMax)),
                    .y = utils.itf(rand.intRangeAtMost(i32, rangeMin, rangeMax)),
                },
                .color = rl.Color.green,
            },
            .id = i,
        };
        while (!particle.robot.checkCollision()) {
            particle.robot.center = rl.Vector2{
                .x = utils.itf(rand.intRangeAtMost(i32, rangeMin, rangeMax)),
                .y = utils.itf(rand.intRangeAtMost(i32, rangeMin, rangeMax)),
            };
        }
        particles[i] = particle;
    }
    return particles;
}

/// Updates the particles (random movement)
pub fn updateParticles(particles: []Particle, rand: *std.Random) void {
    for (particles) |*particle| {
        particle.robot.update(rand, false);
    }
}

const Probability = struct {
    prob: f32,
    position: rl.Vector2,
};

const sdev = 5;

/// Re-samples the particles and moves them accordingly
pub fn resample(particles: []Particle, comptime PARTICLE_COUNT: i32, normal: zprob.Normal(f32), uniformDist: zprob.Uniform(f32), robot: *bot.Robot) rl.Vector2 {
    var probabilities = [_]Probability{undefined} ** PARTICLE_COUNT;

    const rdT = robot.distanceFromSide(0, uniformDist, false);
    const rdR = robot.distanceFromSide(1, uniformDist, false);
    const rdB = robot.distanceFromSide(2, uniformDist, false);
    const rdL = robot.distanceFromSide(3, uniformDist, false);

    for (particles, 0..) |*particle, i| {
        const dT = rdT - particle.robot.distanceFromSide(0, uniformDist, true);
        const dR = rdR - particle.robot.distanceFromSide(1, uniformDist, true);
        const dB = rdB - particle.robot.distanceFromSide(2, uniformDist, true);
        const dL = rdL - particle.robot.distanceFromSide(3, uniformDist, true);

        var weight: f32 = 0.0;
        weight += -(dT * dT) / (2.0 * sdev * sdev);
        weight += -(dR * dR) / (2.0 * sdev * sdev);
        weight += -(dB * dB) / (2.0 * sdev * sdev);
        weight += -(dL * dL) / (2.0 * sdev * sdev);
        weight += -4 * (std.math.log(f32, std.math.e, (std.math.sqrt(2.0 * std.math.pi) * sdev)));
        weight = std.math.pow(f32, std.math.e, weight);

        _ = normal; // Needed for compiler
        // const probT = normal.pdf(rdT, dT, sdev) catch 0.0;
        // const probR = normal.pdf(rdR, dR, sdev) catch 0.0;
        // const probB = normal.pdf(rdB, dB, sdev) catch 0.0;
        // const probL = normal.pdf(rdL, dL, sdev) catch 0.0;
        // const weight = probT * probR * probB * probL;
        probabilities[i] = Probability{
            .prob = weight,
            .position = particle.robot.center,
        };
    }
    // Normalize probababilities
    var sumN: f32 = 0.0;
    for (probabilities) |prob| {
        sumN += prob.prob;
    }
    for (probabilities[0..]) |*prob| {
        if (sumN == 0) {
            prob.prob = 1 / PARTICLE_COUNT;
            continue;
        }
        prob.prob /= sumN;
    }

    // Sort probabilities
    std.mem.sort(Probability, &probabilities, {}, comptime sortProbabilities());

    // Get the number of probabilities that just add up to 1+;
    var sum: f32 = 0.0;
    var i: usize = 0.0;
    for (probabilities) |prob| {
        sum += prob.prob;
        i += 1;
        if (sum > 1)
            break;
    }

    // For each of those probabilities, calculate about how many particles
    // represent that percentage of the total
    // Then for each of those
    for (0..i) |j| {
        const count: u64 = lib.ftu(@trunc(@as(f64, probabilities[j].prob) * PARTICLE_COUNT));
        for (0..count) |k| {
            particles[k].robot.center = probabilities[j].position;
        }
    }

    var avgX: f32 = 0;
    var avgY: f32 = 0;

    for (particles) |particle| {
        avgX += particle.robot.center.x;
        avgY += particle.robot.center.y;
    }
    avgX /= PARTICLE_COUNT;
    avgY /= PARTICLE_COUNT;
    return rl.Vector2{ .x = avgX, .y = avgY };
}

fn sortProbabilities() fn (void, Probability, Probability) bool {
    return struct {
        pub fn inner(_: void, a: Probability, b: Probability) bool {
            return a.prob < b.prob;
        }
    }.inner;
}
