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
    rl.initWindow(1500, 700, "MCL Simulation");
    rl.setTargetFPS(10);

    defer rl.closeWindow();

    // Load a font or use the default; Also defer unloading it
    font = rl.loadFontEx("assets/fonts/Asap-VariableFont_wdth,wght.ttf", 24, null) catch f: {
        rl.traceLog(rl.TraceLogLevel.err, "Couldn't load font...", .{});

        // If this breaks too, you're just cooked.
        break :f rl.getFontDefault() catch unreachable;
    };
    defer rl.unloadFont(font);

    // Define the robots
    const CENTER = rl.Vector2{ .x = 125, .y = 125 };
    var robot = lib.Robot{ .center = CENTER };
    var robotAcc = lib.Robot{ .center = CENTER, .color = rl.Color.blue };
    var mclBot = lib.Robot{ .center = CENTER, .color = rl.Color.pink };
    // Define the particles
    const PARTICLE_COUNT = 2000;
    var particles = lib.initParticles(PARTICLE_COUNT, uniformDist);
    // While window should stay open...
    while (!rl.windowShouldClose()) {
        // Updates

        // Handle inputs
        robot.update(rand, true); // Estimated robot uses exact movement
        robotAcc.update(rand, false); // Actual robot uses random movement
        robotAcc.updateKidnap(uniformDist);
        lib.updateParticles(particles[0..], rand);
        mclBot = lib.resample(particles[0..], PARTICLE_COUNT, normal, uniformDist, &robotAcc);

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
        drawText("%d FPS - %.0fms Update Time", .{ rl.getFPS(), 1.0 / (if (rl.getFPS() > 0) lib.itf(rl.getFPS()) else 1.0) * 1000 }, 700, 50, rl.Color.red);

        drawText("Robot's Actual Position [w/ noise]:", .{}, 700, 100, rl.Color.blue);
        drawText("(%.2f, %.2f)", .{ robotAcc.center.x, robotAcc.center.y }, 1250, 100, rl.Color.blue);

        drawText("Robot's control tracked position [w/o noise]:", .{}, 700, 125, rl.Color.orange);
        drawText("(%.2f, %.2f)", .{ robot.center.x, robot.center.y }, 1250, 125, rl.Color.orange);

        drawText("Robot's MCL Estimated Position:", .{}, 700, 150, rl.Color.pink);
        drawText("(%.2f, %.2f)", .{ mclBot.center.x, mclBot.center.y }, 1250, 150, rl.Color.pink);

        drawText("Particles", .{}, 700, 175, rl.Color.green);

        drawText("Particle Count: %d", .{particles.len}, 700, 200, rl.Color.black);

        drawText("MCL Simulation by @TalinTheDev", .{}, 700, 475, rl.Color.black);
        drawText("Controls: ", .{}, 700, 520, rl.Color.black);
        drawText("- W/A/S/D for Translational Movement: ", .{}, 700, 545, rl.Color.black);
        drawText("- Left/Right Arrow Keys for Rotational Movement: ", .{}, 700, 570, rl.Color.black);
        drawText("- K to Kidnap Robot (disappointing MCL results)", .{}, 700, 595, rl.Color.black);
        drawText("- ESC to quit", .{}, 700, 620, rl.Color.black);

        // End drawing
        rl.endDrawing();
    }
}

pub fn drawText(text: [:0]const u8, args: anytype, x: f32, y: f32, color: rl.Color) void {
    rl.drawTextEx(font, rl.textFormat(text, args), rl.Vector2{ .x = x, .y = y }, 24, 1.0, color);
}
