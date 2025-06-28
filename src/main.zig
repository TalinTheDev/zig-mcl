// Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
//! Project root

// Imports
const lib = @import("zig_mcl_lib");
const rl = @import("raylib");
const std = @import("std");

// Global Variables
var font: rl.Font = undefined;

// Game entry point
pub fn main() !void {
    // Create a random number generator
    var prng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        std.posix.getrandom(std.mem.asBytes(&seed)) catch unreachable;
        break :blk seed;
    });
    var random = prng.random();
    var rand = &random;
    _ = &rand;

    // Initialize window and OpenGL context; Also defer closing both
    rl.initWindow(1350, 700, "MCL Simulation");
    rl.setTargetFPS(10);

    defer rl.closeWindow();

    // Load a font or use the default; Also defer unloading it
    font = rl.loadFont("assets/fonts/Asap-VariableFont_wdth,wght.ttf") catch f: {
        rl.traceLog(rl.TraceLogLevel.err, "Couldn't load font...", .{});

        // If this breaks too, you're just cooked.
        break :f rl.getFontDefault() catch unreachable;
    };
    defer rl.unloadFont(font);

    // Define the robots
    var robot = lib.Robot{ .center = rl.Vector2{ .x = 345, .y = 345 } };
    var robotAcc = lib.Robot{ .center = rl.Vector2{ .x = 345, .y = 345 }, .color = rl.Color.blue };

    // Define the particles
    const PARTICLE_COUNT = 500;
    var particles = lib.initParticles(PARTICLE_COUNT, rand);

    // While window should stay open...
    while (!rl.windowShouldClose()) {
        // Updates

        // Handle inputs
        robot.update(rand, true); // Estimated robot uses exact movement
        robotAcc.update(rand, false); // Actual robot uses random movement
        lib.updateParticles(particles[0..], rand);

        // Begin drawing and clear screen
        rl.beginDrawing();
        rl.clearBackground(rl.Color.white);

        // Draw particles
        for (particles[0..PARTICLE_COUNT]) |particle| {
            rl.drawCircleV(particle.robot.center, particle.robot.radius, particle.robot.color);
        }

        // Draw field & robots
        rl.drawRectangleLinesEx(lib.field.field, 5.0, rl.Color.black);
        rl.drawCircleV(robot.center, robot.radius, robot.color);
        rl.drawCircleV(robotAcc.center, robotAcc.radius, robotAcc.color);

        // Draw debug text
        drawText("%d FPS", .{rl.getFPS()}, 700, 50, rl.Color.red);
        drawText("Actual Robot", .{}, 700, 100, rl.Color.blue);
        drawText("Estimated Robot", .{}, 700, 125, rl.Color.orange);
        drawText("Simulated Robot", .{}, 700, 150, rl.Color.green);

        drawText("Robot Estimated Position: (%.2f, %.2f)", .{ robot.center.x, robot.center.y }, 700, 200, rl.Color.black);
        drawText("Robot Actual Position: (%.2f, %.2f)", .{ robotAcc.center.x, robotAcc.center.y }, 700, 225, rl.Color.black);

        drawText("Particle Count: %d", .{particles.len}, 700, 275, rl.Color.black);
        // End drawing
        rl.endDrawing();
    }
}

pub fn drawText(text: [:0]const u8, args: anytype, x: f32, y: f32, color: rl.Color) void {
    rl.drawTextEx(font, rl.textFormat(text, args), rl.Vector2{ .x = x, .y = y }, 28, 1.0, color);
}
