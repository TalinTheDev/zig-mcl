// Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
//! Project root

// Imports
const lib = @import("zig_mcl_lib");
const rl = @import("raylib");
const std = @import("std");
const zprob = @import("zprob");

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

    // Setup distribution generator
    const seed: u64 = @intCast(std.time.microTimestamp());
    var prngD = std.Random.DefaultPrng.init(seed);
    var randD = prngD.random();
    const normal = zprob.Normal(f32).init(&randD);
    const uniformDist = zprob.Uniform(f32).init(&randD);
    _, _ = .{ normal, uniformDist };
    // Initialize window and OpenGL context; Also defer closing both
    rl.initWindow(1350, 700, "MCL Simulation");
    rl.setTargetFPS(30);

    defer rl.closeWindow();

    // Load a font or use the default; Also defer unloading it
    font = rl.loadFont("assets/fonts/Asap-VariableFont_wdth,wght.ttf") catch f: {
        rl.traceLog(rl.TraceLogLevel.err, "Couldn't load font...", .{});

        // If this breaks too, you're just cooked.
        break :f rl.getFontDefault() catch unreachable;
    };
    defer rl.unloadFont(font);

    // Define the robots
    const CENTER = rl.Vector2{ .x = 345, .y = 345 };
    var robot = lib.Robot{ .center = CENTER };
    var robotAcc = lib.Robot{ .center = CENTER, .color = rl.Color.blue };
    var mclBot = lib.Robot{ .center = CENTER, .color = rl.Color.pink };
    // Define the particles
    const PARTICLE_COUNT = 1000;
    var particles = lib.initParticles(PARTICLE_COUNT, rand);
    // While window should stay open...
    while (!rl.windowShouldClose()) {
        // Updates

        // Handle inputs
        robot.update(rand, true); // Estimated robot uses exact movement
        robotAcc.update(rand, false); // Actual robot uses random movement
        lib.updateParticles(particles[0..], rand);
        const mclEst = lib.resample(particles[0..], PARTICLE_COUNT, normal, uniformDist, &robot);
        mclBot = lib.Robot{ .center = mclEst, .color = rl.Color.pink };

        // Begin drawing and clear screen
        rl.beginDrawing();
        rl.clearBackground(rl.Color.white);

        // Draw particles
        for (particles[0..PARTICLE_COUNT]) |*particle| {
            particle.robot.draw();
        }
        robot.draw();
        robotAcc.draw();
        mclBot.updateAfterRotation();
        mclBot.draw();

        // Draw field & robots
        for (0..lib.walls.len) |i| {
            const wall = lib.walls[i];
            rl.drawLineEx(wall.start, wall.end, wall.width, rl.Color.black);
        }

        // Draw debug text
        drawText("%d FPS", .{rl.getFPS()}, 700, 50, rl.Color.red);
        drawText("Actual (movement includes error) Robot", .{}, 700, 100, rl.Color.blue);
        drawText("Estimated (perfect movement) Robot", .{}, 700, 125, rl.Color.orange);
        drawText("Simulated (particles) Robot", .{}, 700, 150, rl.Color.green);
        drawText("MCL Estimated (position as given by MCL) Robot", .{}, 700, 175, rl.Color.pink);

        drawText("Robot Actual Position: (%.2f, %.2f)", .{ robotAcc.center.x, robotAcc.center.y }, 700, 225, rl.Color.black);
        drawText("Robot Estimated Position: (%.2f, %.2f)", .{ robot.center.x, robot.center.y }, 700, 250, rl.Color.black);
        drawText("Robot MCL Estimated Position: (%.2f, %.2f)", .{ mclEst.x, mclEst.y }, 700, 275, rl.Color.black);

        drawText("Particle Count: %d", .{particles.len}, 700, 325, rl.Color.black);

        drawText("MCL Simulation (by @TalinTheDev)", .{}, 700, 400, rl.Color.black);
        drawText("Currently:", .{}, 700, 425, rl.Color.black);
        drawText("- Doesn't do MCL now that I added in headings", .{}, 725, 450, rl.Color.black);

        // End drawing
        rl.endDrawing();
    }
}

pub fn drawText(text: [:0]const u8, args: anytype, x: f32, y: f32, color: rl.Color) void {
    rl.drawTextEx(font, rl.textFormat(text, args), rl.Vector2{ .x = x, .y = y }, 28, 1.0, color);
}
