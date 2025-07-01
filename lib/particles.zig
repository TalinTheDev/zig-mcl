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
pub fn initParticles(comptime count: i32, uniformDist: zprob.Uniform(f32)) [count]Particle {
    var particles = [_]Particle{undefined} ** count;
    for (0..count) |i| {
        particles[i] = Particle{
            .robot = randomBotPos(uniformDist, rl.Color.green),
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

const Probability = struct {
    prob: f32,
    position: rl.Vector2,
};

const sdev = 0.1;
var firstRun = false;

/// Returns a robot at a random position
fn randomBotPos(uniformDist: zprob.Uniform(f32), color: rl.Color) bot.Robot {
    const rangeMin = wall.walls[0].start.x + 12.5;
    const rangeMax = wall.walls[0].end.x - 12.5;
    var robot = bot.Robot{
        .center = rl.Vector2{
            .x = uniformDist.sample(rangeMin, rangeMax),
            .y = uniformDist.sample(rangeMin, rangeMax),
        },
        .color = color,
    };
    while (!robot.checkCollision()) {
        robot.center = rl.Vector2{
            .x = uniformDist.sample(rangeMin, rangeMax),
            .y = uniformDist.sample(rangeMin, rangeMax),
        };
    }
    return robot;
}

fn compute_n_eff(probs: []Probability, comptime PARTICLE_COUNT: i32) f32 {
    var sum_sq: f32 = 0.0;
    for (0..PARTICLE_COUNT) |p| {
        sum_sq += std.math.pow(f32, probs[p].prob, 2);
    }
    if (sum_sq == 0.0) return 0.0;
    return 1.0 / sum_sq;
}
var resampleFrames: i32 = 0;
var frames: i32 = 0;
var resuce: i32 = 100;
/// Re-samples the particles and moves them accordingly
pub fn resample(particles: []Particle, comptime PARTICLE_COUNT: i32, normal: zprob.Normal(f32), uniformDist: zprob.Uniform(f32), robot: *bot.Robot) bot.Robot {
    if (resampleFrames <= 10) {
        resampleFrames = 0;
        if (!firstRun) {
            for (0..lib.ftu(@floor(@as(f32, @floatFromInt(particles.len)) * 0.75))) |i| {
                particles[i].robot.center.x = 125;
                particles[i].robot.center.y = 125;
            }
            firstRun = true;
            return bot.Robot{ .center = rl.Vector2{ .x = 125, .y = 125 }, .color = rl.Color.pink };
        }
        const extraTotal = comptime (PARTICLE_COUNT + (lib.itf(PARTICLE_COUNT) * 0.05));
        var probabilities = [_]Probability{undefined} ** extraTotal;

        const robotDist = robot.distanceToClosestSide(uniformDist, false);
        const rdT = robotDist[0];
        const rdR = robotDist[1];
        const rdB = robotDist[2];
        const rdL = robotDist[3];

        for (0..(extraTotal - PARTICLE_COUNT)) |i| {
            var particle = Particle{
                .robot = randomBotPos(uniformDist, rl.Color.green),
                .id = i,
            };

            const particleDist = particle.robot.distanceToClosestSide(uniformDist, false);
            const dT = particleDist[0];
            const dR = particleDist[1];
            const dB = particleDist[2];
            const dL = particleDist[3];

            // var weight: f32 = 0.0;
            // weight += -(dT * dT) / (2.0 * sdev * sdev);
            // weight += -(dR * dR) / (2.0 * sdev * sdev);
            // weight += -(dB * dB) / (2.0 * sdev * sdev);
            // weight += -(dL * dL) / (2.0 * sdev * sdev);
            // weight += -4 * (std.math.log(f32, std.math.e, (std.math.sqrt(2.0 * std.math.pi) * sdev)));
            // weight = std.math.pow(f32, std.math.e, weight);
            const probT = normal.pdf(rdT, dT, sdev) catch 0.0;
            const probR = normal.pdf(rdR, dR, sdev) catch 0.0;
            const probB = normal.pdf(rdB, dB, sdev) catch 0.0;
            const probL = normal.pdf(rdL, dL, sdev) catch 0.0;
            const weight = probT * probR * probB * probL;
            // var log_weight: f32 = 0.0;
            // log_weight += std.math.log(f32, probT, std.math.e);
            // log_weight += std.math.log(f32, probR, std.math.e);
            // log_weight += std.math.log(f32, probB, std.math.e);
            // log_weight += std.math.log(f32, probL, std.math.e);
            // const weight = std.math.exp(log_weight);
            probabilities[PARTICLE_COUNT - 1 + i] = Probability{
                .prob = weight,
                .position = particle.robot.center,
            };
        }
        for (particles, 0..) |*particle, i| {
            const particleDist = particle.robot.distanceToClosestSide(uniformDist, false);
            const dT = particleDist[0];
            const dR = particleDist[1];
            const dB = particleDist[2];
            const dL = particleDist[3];

            // var weight: f32 = 0.0;
            // weight += -(dT * dT) / (2.0 * sdev * sdev);
            // weight += -(dR * dR) / (2.0 * sdev * sdev);
            // weight += -(dB * dB) / (2.0 * sdev * sdev);
            // weight += -(dL * dL) / (2.0 * sdev * sdev);
            // weight += -4 * (std.math.log(f32, std.math.e, (std.math.sqrt(2.0 * std.math.pi) * sdev)));
            // weight = std.math.pow(f32, std.math.e, weight);

            // _ = normal; // Needed for compiler
            const probT = normal.pdf(rdT, dT, sdev) catch 0.0;
            const probR = normal.pdf(rdR, dR, sdev) catch 0.0;
            const probB = normal.pdf(rdB, dB, sdev) catch 0.0;
            const probL = normal.pdf(rdL, dL, sdev) catch 0.0;
            const weight = probT * probR * probB * probL;
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
        if (frames >= 30 and resuce <= 0) {
            const n_eff = compute_n_eff(&probabilities, PARTICLE_COUNT);

            if (n_eff < lib.itf(PARTICLE_COUNT) * 0.2) { // 20% of total
                // We are overconfident — optionally inject more randoms
                for (0..(lib.ftu(@floor(lib.itf(PARTICLE_COUNT) / 10)))) |i| {
                    particles[i].robot = randomBotPos(uniformDist, rl.Color.green);
                }
                // Trust
                return randomBotPos(uniformDist, rl.Color.pink);
            }
            frames = 0;
            resuce = 100;
        } else {
            frames += 1;
            resuce -= 1;
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
            const count: u64 = lib.ftu(@min(PARTICLE_COUNT - 1, @trunc(@as(f64, probabilities[j].prob) * extraTotal)));
            for (0..count) |k| {
                particles[k].robot.center = probabilities[j].position;
            }
        }

        var avgX: f32 = 0;
        var avgY: f32 = 0;
        var avgHeading: f32 = 0;
        var totalW: f32 = 0;
        for (particles) |particle| {
            totalW += probabilities[particle.id].prob;
            avgX += particle.robot.center.x * probabilities[particle.id].prob;
            avgY += particle.robot.center.y * probabilities[particle.id].prob;
            avgHeading += particle.robot.heading * probabilities[particle.id].prob;
        }
        avgX /= totalW;
        avgY /= totalW;
        avgHeading /= totalW;

        return bot.Robot{ .center = rl.Vector2{
            .x = avgX,
            .y = avgY,
        }, .heading = avgHeading, .color = rl.Color.pink };
    }
    resampleFrames += 1;
    return randomBotPos(uniformDist, rl.Color.pink);
}

fn sortProbabilities() fn (void, Probability, Probability) bool {
    return struct {
        pub fn inner(_: void, a: Probability, b: Probability) bool {
            return a.prob > b.prob;
        }
    }.inner;
}
