// Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
//! Project root

// Imports
const lib = @import("zig_mcl_lib");
const rl = @import("raylib");
const std = @import("std");

// Game entry point
pub fn main() !void {
    // Initialize window and OpenGL context; Also defer closing both
    rl.initWindow(1350, 700, "MCL Simulation");
    rl.setTargetFPS(60);
    defer rl.closeWindow();

    // Load a font or use the default; Also defer unloading it
    const font = rl.loadFont("assets/fonts/Asap-VariableFont_wdth,wght.ttf") catch f: {
        rl.traceLog(rl.TraceLogLevel.err, "Couldn't load font...", .{});

        // If this breaks too, you're just cooked.
        break :f rl.getFontDefault() catch unreachable;
    };
    defer rl.unloadFont(font);

    // Define the robot
    var robot = lib.Robot{ .center = rl.Vector2{ .x = 345, .y = 345 } };

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
        if (lib.checkFieldCollision(robot, lib.field.walls[0])) {
            robot.center.y = lib.field.walls[0].start.y + 15;
        }
        if (lib.checkFieldCollision(robot, lib.field.walls[1])) {
            robot.center.x = lib.field.walls[1].start.x - 15;
        }
        if (lib.checkFieldCollision(robot, lib.field.walls[2])) {
            robot.center.y = lib.field.walls[2].start.y - 15;
        }
        if (lib.checkFieldCollision(robot, lib.field.walls[3])) {
            robot.center.x = lib.field.walls[3].start.x + 15;
        }

        // Begin drawing and clear screen
        rl.beginDrawing();
        rl.clearBackground(rl.Color.white);

        // Draw field & robot
        rl.drawRectangleLinesEx(lib.field.field, 5.0, rl.Color.black);
        rl.drawCircleV(robot.center, robot.radius, robot.color);

        // Draw debug text
        rl.drawTextEx(font, rl.textFormat("%d FPS", .{rl.getFPS()}), rl.Vector2{ .x = 700, .y = 50 }, 28, 1.0, rl.Color.blue);
        rl.drawTextEx(font, rl.textFormat("Robot Position: (%.2f, %.2f)", .{ robot.center.x, robot.center.y }), rl.Vector2{ .x = 700, .y = 100 }, 28, 1.0, rl.Color.black);

        rl.drawTextEx(font, rl.textFormat("Robot Distance From Top: %.2f", .{robot.distanceFromSide(lib.field.walls[0])}), rl.Vector2{ .x = 700, .y = 125 }, 28, 1.0, rl.Color.black);
        rl.drawTextEx(font, rl.textFormat("Robot Distance From Right: %.2f", .{robot.distanceFromSide(lib.field.walls[1])}), rl.Vector2{ .x = 700, .y = 150 }, 28, 1.0, rl.Color.black);
        rl.drawTextEx(font, rl.textFormat("Robot Distance From Bottom: %.2f", .{robot.distanceFromSide(lib.field.walls[2])}), rl.Vector2{ .x = 700, .y = 175 }, 28, 1.0, rl.Color.black);
        rl.drawTextEx(font, rl.textFormat("Robot Distance From Left: %.2f", .{robot.distanceFromSide(lib.field.walls[3])}), rl.Vector2{ .x = 700, .y = 200 }, 28, 1.0, rl.Color.black);

        // End drawing
        rl.endDrawing();
    }
}
