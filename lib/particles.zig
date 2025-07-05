// Copyright 2025 Talin Sharma and Alex Oh. Subject to the Apache-2.0 license.
//! Contains the logic for the simulation's particles

// Imports
const rl = @import("raylib");
const bot = @import("bot.zig");
const std = @import("std");
const utils = @import("utils.zig");
const wall = @import("wall.zig");
const zprob = @import("zprob");
const lib = @import("root.zig");
const config = @import("config.zig");

const N = config.PARTICLE_COUNT;
var rescatterFrames: f32 = 0.0;

/// Represents a particle
pub const Particle = struct {
    robot: bot.Robot,
    weight: f32,
    id: usize,
};

/// Returns an array of particles with their position being randomly generated
/// within the field's boundaries
pub fn initParticles(randEnv: *zprob.RandomEnvironment) []Particle {
    var particles = std.heap.page_allocator.alloc(Particle, N) catch unreachable; // Create an array of count particles
    for (0..N) |i| {
        particles[i] = Particle{
            .robot = randomBotPos(randEnv, rl.Color.green), // Assign a simulated robot at a random position
            .weight = 1.0 / lib.itf(N), // Initial normalized weight is 1 / number of particles
            .id = i,
        };
    }

    return particles;
}

/// Returns a robot at a random position
fn randomBotPos(randEnv: *zprob.RandomEnvironment, color: rl.Color) bot.Robot {
    // Define min and max positions for x and y axes
    const rangeMin = wall.walls[0].start.x + 12.5;
    const rangeMax = wall.walls[0].end.x - 12.5;

    // Create and initialize simulated robot
    var robot = bot.Robot.init(rl.Vector2{
        .x = lib.ftf(randEnv.rUniform(rangeMin, rangeMax)),
        .y = lib.ftf(randEnv.rUniform(rangeMin, rangeMax)),
    }, -90, color, true);

    // If robot is colliding, move to a different position
    while (robot.checkCollision()) {
        robot.setPos(lib.ftf(randEnv.rUniform(rangeMin, rangeMax)), lib.ftf(randEnv.rUniform(rangeMin, rangeMax)));
    }

    return robot;
}

pub fn scatter(particles: *[]Particle, randEnv: *zprob.RandomEnvironment, robot: *bot.Robot) void {
    for (particles.*) |*p| {
        p.robot = randomBotPos(randEnv, rl.Color.green);
        p.robot.heading = robot.heading;
    }
}

/// Updates the particles in four steps: movement, weight calculation, finding estimated robot position, and resampling. Returns the estimated robot
pub fn updateParticles(particles: *[]Particle, randEnv: *zprob.RandomEnvironment, robot: *bot.Robot) bot.Robot {
    // Update the position of each particle's simulated robot based on actual robot movement
    for (particles.*) |*particle| {
        particle.robot.update(false, randEnv, robot.realSpeed, robot.realAngularSpeed);
    }

    calculateWeights(particles, randEnv, robot);
    const estimatedBot = bestEstimate(particles.*);
    resample(particles, randEnv);
    rescatterFrames += 1;

    return estimatedBot;
}

/// Calculates weights for each particle by comparing simulated sensor readings with the actual sensor readings and a normal distribution
pub fn calculateWeights(particles: *[]Particle, randEnv: *zprob.RandomEnvironment, robot: *bot.Robot) void {
    // Get list of distance sensor readings of the actual robot
    const robotDist = robot.distanceToClosestSide(false, randEnv);

    // Loop through each particle and calculate the weight
    for (particles.*) |*particle| {
        // Get list of distance sensor readings of the simulated robot
        const particleDist = particle.robot.distanceToClosestSide(true, randEnv);
        var weight: f32 = 1.0;

        // Loop through each sensor and get the probability of the simulated sensor's reading based on the normal distribution of the actual robot's sensor reading
        for (0..particleDist.len) |i| {
            weight *= lib.ftf(randEnv.dNormal(particleDist[i], robotDist[i], config.SENSOR_STDEV, false) catch {
                std.debug.print("particleDist: {d}, robotDist: {d}", .{ particleDist[i], robotDist[i] });
                return;
            });
        }

        // Calculate weight for angle
        var angleDiff = @abs(robot.heading - particle.robot.heading);
        if (angleDiff > 180.0) {
            angleDiff = 360.0 - angleDiff; // Angle should be between 0 and 180
        }

        weight *= lib.ftf(randEnv.dNormal(angleDiff, 0.0, 20.0, false) catch {
            std.debug.print("angleDiff: {d}", .{angleDiff});
            return;
        });

        particle.weight = weight;
    }

    // Get greatest weight
    var greatest: f32 = 0.0;
    for (particles.*) |p| {
        if (p.weight > greatest) {
            greatest = p.weight;
        }
    }

    // Rescatter if greatest weight is too low
    if (greatest < config.RESCATTER_MAX_WEIGHT and rescatterFrames > config.RESCATTER_DELAY * lib.itf(rl.getFPS())) {
        scatter(particles, randEnv, robot);
        rescatterFrames = 0; // Prevents rescattering from occuring too often
        calculateWeights(particles, randEnv, robot);
    }

    // Normalize weights
    normalizeWeights(particles);
}

// Adds up all the weights
fn totalWeights(particles: *[]Particle) f32 {
    var sum: f32 = 0.0;

    for (particles.*) |p| {
        sum += p.weight;
    }

    return sum;
}

/// Scales all weights so that the sum of the weights is 1
fn normalizeWeights(particles: *[]Particle) void {
    const total = totalWeights(particles);

    // Divide all weights by total
    for (particles.*) |*p| {
        p.weight /= total;
    }
}

/// Returns a robot with the best estimate for the location of the actual robot using a weighted average of the particle positions
pub fn bestEstimate(particles: []Particle) bot.Robot {
    var sumWeights: f32 = 0.0;
    var sumX: f32 = 0.0;
    var sumY: f32 = 0.0;
    var sumAngleY: f32 = 0.0;
    var sumAngleX: f32 = 0.0;

    // Calculate the sum of the weights (should be normalized, but just in case) and the weighted sum for the x and y coordinates
    for (particles) |p| {
        sumWeights += p.weight;
        sumX += p.weight * p.robot.pos.x;
        sumY += p.weight * p.robot.pos.y;
        sumAngleY += p.weight * @sin(std.math.degreesToRadians(p.robot.heading));
        sumAngleX += p.weight * @cos(std.math.degreesToRadians(p.robot.heading));
    }

    // Divide the weighted sum by total to get weighted average
    const pos = rl.Vector2{ .x = sumX / sumWeights, .y = sumY / sumWeights };
    const heading = std.math.radiansToDegrees(std.math.atan2(sumAngleY, sumAngleX));
    return bot.Robot.init(pos, heading, rl.Color.pink, false);
}

/// Calculates effective sample size (N eff) for handling degeneracy by resampling only when N eff is low
fn effectiveSampleSize(particles: []Particle) f32 {
    var sumWeightsSquared: f32 = 0.0;

    // Formula for N eff is 1 / (w_1^2 + w_2^2 + ... + w_n^2)
    for (particles) |p| {
        sumWeightsSquared += std.math.pow(f32, p.weight, 2);
    }

    if (sumWeightsSquared == 0.0) return @as(f32, @floatFromInt(particles.len)); // Handling divide by zero case
    return 1.0 / sumWeightsSquared;
}

/// Resamples the particles and moves them accordingly
pub fn resample(particles: *[]Particle, randEnv: *zprob.RandomEnvironment) void {
    // Only resample when the effective sample size is less than the threshold (tune the threshold for optimal performance)
    if (effectiveSampleSize(particles.*) < config.THRESHOLD) {
        // Low-variance resampling algorithm

        // This algorithm makes sure the variance in the weights is low
        // while moving lower-weighted particles to positions with higher weights
        // The particle count remains the same

        var newParticles = std.heap.page_allocator.alloc(Particle, N) catch unreachable; // New array of particles
        var U: f32 = lib.ftf(randEnv.rUniform(0, 1.0 / lib.itf(N))); // Initial random U value, uniformly from 0 to 1 / number of particles
        var cumulative: f32 = particles.*[0].weight; // Cumulative sum of weights, starts as just the first weight
        var i: usize = 0; // Index of the particle chosen to be resampled

        for (0..N) |n| { // N particles will be resampled, one for every iteration
            U += 1.0 / lib.itf(N); // Increment U by 1 / number of particles (weight when all particles have equal weights)
            while (U > cumulative and i < particles.len - 2) { // Add weights to cumulative until the cumulative weight is greater than U. The last weight added will be resampled
                i += 1; // Increment the index of the chosen particle by 1
                cumulative += particles.*[i].weight; // Cumulatively add the weight of the particles starting from the first
            }

            newParticles[n] = particles.*[i]; // Resample the chosen particle into the new array
            cumulative = particles.*[0].weight; // Reset cumulative
            i = 0; // Reset index
        }

        std.heap.page_allocator.free(particles.*);
        particles.* = newParticles;
        normalizeWeights(particles);
    }
}
