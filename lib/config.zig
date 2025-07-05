// Copyright 2025 Talin Sharma and Alex Oh. Subject to the Apache-2.0 license.
//! Contains all adjustable constants

// Imports
const lib = @import("root.zig");
const rl = @import("raylib");

// Robot start position
pub const CENTER = rl.Vector2{ .x = 125, .y = 125 };

// Tuning constants
pub const PARTICLE_COUNT: i32 = 2000; // Number of particles
pub const THRESHOLD: f32 = lib.itf(PARTICLE_COUNT) * 0.8; // Minimum effective sample size before resampling. Tune this for optimal performance: higher threshold = more resampling
pub const ACTUAL_SENSOR_STDEV: f32 = 10.0; // Standard deviation for the actual robot's sensor noise
pub const SENSOR_STDEV: f32 = 10.0; // Standard deviation for comparing simulated sensor readings using normal pdf
pub const SPEED_STDEV: f32 = 15.0; // Standard deviation for all robot speeds
pub const ANGULAR_SPEED_STDEV: f32 = 30.0; // Standard deviation for all robot angular speeds
pub const RESCATTER_MAX_WEIGHT: f32 = 1.0e-12; // If the greatest weight falls below this value, rescattering occurs
pub const RESCATTER_DELAY: f32 = 1.0; // Wait between rescattering in seconds
