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
    rl.setTargetFPS(6);
    defer rl.closeWindow();

    // Load a font or use the default; Also defer unloading it
    font = rl.loadFont("assets/fonts/Asap-VariableFont_wdth,wght.ttf") catch f: {
        rl.traceLog(rl.TraceLogLevel.err, "Couldn't load font...", .{});

        // If this breaks too, you're just cooked.
        break :f rl.getFontDefault() catch unreachable;
    };
    defer rl.unloadFont(font);

    // Define the robot
    var robot = lib.Robot{ .center = rl.Vector2{ .x = 345, .y = 345 } };

    // Define the particles
    const PARTICLE_COUNT = 500;
    const particles = lib.initParticles(PARTICLE_COUNT, rand);

    // While window should stay open...
    while (!rl.windowShouldClose()) {
        // Updates

        // Handle inputs
        if (lib.keyPressed(lib.MOVE.UP)) {
            robot.center.y -= 10;
        }
        if (lib.keyPressed(lib.MOVE.DOWN)) {
            robot.center.y += 10;
        }
        if (lib.keyPressed(lib.MOVE.LEFT)) {
            robot.center.x -= 10;
        }
        if (lib.keyPressed(lib.MOVE.RIGHT)) {
            robot.center.x += 10;
        }

        // Check field wall collisions
        if (lib.checkFieldCollision(robot, 0)) {
            robot.center.y = lib.field.walls[0].start.y + 15;
        }
        if (lib.checkFieldCollision(robot, 1)) {
            robot.center.x = lib.field.walls[1].start.x - 15;
        }
        if (lib.checkFieldCollision(robot, 2)) {
            robot.center.y = lib.field.walls[2].start.y - 15;
        }
        if (lib.checkFieldCollision(robot, 3)) {
            robot.center.x = lib.field.walls[3].start.x + 15;
        }

        // Begin drawing and clear screen
        rl.beginDrawing();
        rl.clearBackground(rl.Color.white);

        // Draw particles
        for (particles[0..PARTICLE_COUNT]) |particle| {
            rl.drawCircleV(particle.robot.center, particle.robot.radius, particle.robot.color);
        }

        // Draw field & robot
        rl.drawRectangleLinesEx(lib.field.field, 5.0, rl.Color.black);
        rl.drawCircleV(robot.center, robot.radius, robot.color);

        // Draw debug text
        drawText("%d FPS", .{rl.getFPS()}, 700, 50, rl.Color.blue);
        drawText("Robot Position: (%.2f, %.2f)", .{ robot.center.x, robot.center.y }, 700, 100, rl.Color.black);

        drawText("Robot Distance From Top: %.2f", .{robot.distanceFromSide(0)}, 700, 125, rl.Color.black);
        drawText("Robot Distance From Right: %.2f", .{robot.distanceFromSide(1)}, 700, 150, rl.Color.black);
        drawText("Robot Distance From Bottom: %.2f", .{robot.distanceFromSide(2)}, 700, 175, rl.Color.black);
        drawText("Robot Distance From Left: %.2f", .{robot.distanceFromSide(3)}, 700, 200, rl.Color.black);

        drawText("Particle Count: %d", .{particles.len}, 700, 250, rl.Color.black);
        // End drawing
        rl.endDrawing();
    }
}

pub fn drawText(text: [:0]const u8, args: anytype, x: f32, y: f32, color: rl.Color) void {
    rl.drawTextEx(font, rl.textFormat(text, args), rl.Vector2{ .x = x, .y = y }, 28, 1.0, color);
}
