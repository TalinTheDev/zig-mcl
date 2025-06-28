// Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
//! Project root

// Imports
const lib = @import("zig_mcl_lib");
const rl = @import("raylib");
const std = @import("std");

const Robot = struct {
    center: rl.Vector2,
    radius: f32 = 10,
    color: rl.Color = rl.Color.orange,
};

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

    // Define the field & its boundaries
    const field = rl.Rectangle{ .x = 50, .y = 50, .width = 600, .height = 600 };
    const fieldTop = .{
        .start = rl.Vector2{ .x = 50, .y = 50 },
        .end = rl.Vector2{ .x = 650, .y = 50 },
    };
    const fieldRight = .{
        .start = fieldTop.end,
        .end = rl.Vector2{ .x = 650, .y = 650 },
    };
    const fieldBottom = .{
        .start = fieldRight.end,
        .end = rl.Vector2{ .x = 50, .y = 650 },
    };
    const fieldLeft = .{
        .start = fieldBottom.end,
        .end = fieldTop.start,
    };

    // Define the robot
    var robot = Robot{ .center = rl.Vector2{ .x = 345, .y = 345 } };

    // While window should stay open...
    while (!rl.windowShouldClose()) {
        // Updates

        // Handle inputs
        if (rl.isKeyDown(rl.KeyboardKey.w) or rl.isKeyDown(rl.KeyboardKey.up)) {
            robot.center.y -= 10;
        }
        if (rl.isKeyDown(rl.KeyboardKey.s) or rl.isKeyDown(rl.KeyboardKey.down)) {
            robot.center.y += 10;
        }
        if (rl.isKeyDown(rl.KeyboardKey.a) or rl.isKeyDown(rl.KeyboardKey.left)) {
            robot.center.x -= 10;
        }
        if (rl.isKeyDown(rl.KeyboardKey.d) or rl.isKeyDown(rl.KeyboardKey.right)) {
            robot.center.x += 10;
        }

        // Check field wall collisions
        if (rl.checkCollisionCircleLine(robot.center, robot.radius, fieldTop.start, fieldTop.end)) {
            robot.center.y = fieldTop.start.y + 15;
        } else if (rl.checkCollisionCircleLine(robot.center, robot.radius, fieldRight.start, fieldRight.end)) {
            robot.center.x = fieldRight.start.x - 15;
        }
        if (rl.checkCollisionCircleLine(robot.center, robot.radius, fieldBottom.start, fieldBottom.end)) {
            robot.center.y = fieldBottom.start.y - 15;
        } else if (rl.checkCollisionCircleLine(robot.center, robot.radius, fieldLeft.start, fieldLeft.end)) {
            robot.center.x = fieldLeft.start.x + 15;
        }

        // Begin drawing and clear screen
        rl.beginDrawing();
        rl.clearBackground(rl.Color.white);

        // Draw field & robot
        rl.drawRectangleLinesEx(field, 5.0, rl.Color.black);
        rl.drawCircleV(robot.center, robot.radius, robot.color);

        // Draw debug text
        rl.drawTextEx(font, rl.textFormat("%d FPS", .{rl.getFPS()}), rl.Vector2{ .x = 700, .y = 50 }, 28, 1.0, rl.Color.blue);
        rl.drawTextEx(font, rl.textFormat("Robot Position: (%.2f, %.2f)", .{ robot.center.x, robot.center.y }), rl.Vector2{ .x = 700, .y = 100 }, 28, 1.0, rl.Color.black);

        // End drawing
        rl.endDrawing();
    }
}
