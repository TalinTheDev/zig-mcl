// Copyright 2025 Talin Sharma and Alex Oh. Subject to the Apache-2.0 license.
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
    // Setup distribution generator
    const seed: u64 = @intCast(std.time.microTimestamp());
    var randEnv = try zprob.RandomEnvironment.initWithSeed(seed, std.heap.page_allocator);
    defer randEnv.deinit();

    // Initialize window and OpenGL context; Also defer closing both
    rl.initWindow(1500, 700, "MCL Simulation");
    rl.setTargetFPS(30);

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
    var robot = lib.Robot.init(CENTER, -90, rl.Color.orange, false);
    var robotAcc = lib.Robot.init(CENTER, -90, rl.Color.blue, false);
    var mclBot = lib.Robot.init(CENTER, -90, rl.Color.pink, false);

    // Tuning constants
    const PARTICLE_COUNT: i32 = 2000; // Number of particles
    const THRESHOLD: f32 = lib.itf(PARTICLE_COUNT) * 0.8; // Regulates resampling frequency using effective sample size. Tune this for optimal performance - high threshold = more resampling
    const ACTUAL_SENSOR_STDEV: f32 = 10.0; // Standard deviation for the actual robot's sensor noise
    const SENSOR_STDEV: f32 = 10.0; // Standard deviation for comparing simulated sensor readings using normal pdf
    const SPEED_STDEV: f32 = 15.0; // Standard deviation for all robot speeds
    const ANGULAR_SPEED_STDEV: f32 = 30.0; // Standard deviation for all robot angular speeds

    // Define the particles
    var particles = lib.initParticles(PARTICLE_COUNT, &randEnv);

    // While window should stay open...
    while (!rl.windowShouldClose()) {
        // Updates

        // Handle inputs
        robot.update(true, &randEnv, SPEED_STDEV, ANGULAR_SPEED_STDEV, 0, 0); // Estimated robot uses exact movement
        robotAcc.update(false, &randEnv, SPEED_STDEV, ANGULAR_SPEED_STDEV, 0, 0); // Actual robot uses random movement
        mclBot = lib.updateParticles(&particles, PARTICLE_COUNT, &randEnv, ACTUAL_SENSOR_STDEV, SENSOR_STDEV, SPEED_STDEV, ANGULAR_SPEED_STDEV, THRESHOLD, &robotAcc);

        // Robot kidnapping (moving to random position)
        if (rl.isKeyPressed(rl.KeyboardKey.k)) {
            // Allowed robot positions
            const rangeMin = lib.walls[0].start.x + 12.5;
            const rangeMax = lib.walls[0].end.x - 12.5;

            // Assign random position
            var posX = lib.ftf(randEnv.rUniform(rangeMin, rangeMax));
            var posY = lib.ftf(randEnv.rUniform(rangeMin, rangeMax));

            // Set both robots' positions
            robot.setPos(posX, posY);
            robotAcc.setPos(posX, posY);

            // Move to different location if colliding
            while (robot.checkCollision()) {
                posX = lib.ftf(randEnv.rUniform(rangeMin, rangeMax));
                posY = lib.ftf(randEnv.rUniform(rangeMin, rangeMax));

                robot.setPos(posX, posY);
                robotAcc.setPos(posX, posY);
            }

            robot.updateSensorLoc();
            robotAcc.updateSensorLoc();
        }

        // Begin drawing and clear screen
        rl.beginDrawing();
        rl.clearBackground(rl.Color.white);

        // Draw particles
        for (particles) |*particle| {
            particle.robot.draw();
        }
        robot.draw();
        robotAcc.draw();
        mclBot.updateSensorLoc();
        mclBot.draw();

        // Draw field & robots
        for (0..lib.walls.len) |i| {
            const wall = lib.walls[i];
            rl.drawLineEx(wall.start, wall.end, wall.width, rl.Color.black);
        }

        // Draw debug text
        drawText("%d FPS - %.0fms Update Time", .{ rl.getFPS(), 1.0 / (if (rl.getFPS() > 0) lib.itf(rl.getFPS()) else 1.0) * 1000 }, 700, 50, rl.Color.red);

        drawText("Robot's Actual Position [w/ noise]:", .{}, 700, 100, rl.Color.blue);
        drawText("(%.2f, %.2f)", .{ robotAcc.pos.x, robotAcc.pos.y }, 1250, 100, rl.Color.blue);

        drawText("Robot's control tracked position [w/o noise]:", .{}, 700, 125, rl.Color.orange);
        drawText("(%.2f, %.2f)", .{ robot.pos.x, robot.pos.y }, 1250, 125, rl.Color.orange);

        drawText("Robot's MCL Estimated Position:", .{}, 700, 150, rl.Color.pink);
        drawText("(%.2f, %.2f)", .{ mclBot.pos.x, mclBot.pos.y }, 1250, 150, rl.Color.pink);

        drawText("Particles", .{}, 700, 175, rl.Color.green);

        drawText("Particle Count: %d", .{particles.len}, 700, 200, rl.Color.black);

        drawText("MCL Simulation by @TalinTheDev and @alex-oh205", .{}, 700, 475, rl.Color.black);
        drawText("Controls: ", .{}, 700, 520, rl.Color.black);
        drawText("- W/S or Up/Down Arrow Keys for Forward/Backward Movement", .{}, 700, 545, rl.Color.black);
        drawText("- A/D or Left/Right Arrow Keys for Rotational Movement", .{}, 700, 570, rl.Color.black);
        drawText("- K to Kidnap Robot", .{}, 700, 595, rl.Color.black);
        drawText("- ESC to quit", .{}, 700, 620, rl.Color.black);

        // End drawing
        rl.endDrawing();
    }
}

pub fn drawText(text: [:0]const u8, args: anytype, x: f32, y: f32, color: rl.Color) void {
    rl.drawTextEx(font, rl.textFormat(text, args), rl.Vector2{ .x = x, .y = y }, 24, 1.0, color);
}
