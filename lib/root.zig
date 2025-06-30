// Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
//! Project library root

// Imports
const rl = @import("raylib");
const std = @import("std");
const zprob = @import("zprob");
const bot = @import("bot.zig");
const wall = @import("wall.zig");

// General Re-exports
pub usingnamespace @import("utils.zig");
pub usingnamespace @import("bot.zig");
pub usingnamespace @import("particles.zig");
pub usingnamespace @import("wall.zig");

/// Checks for a horizontal collision between a robot and a wall
pub fn checkHorizontalCollision(robot: *bot.Robot, wallNum: usize, rightX: bool) bool {
    const wallToCheck = wall.walls[wallNum];

    // If the wall isn't a field boundary and the robot is not vertically
    // touching the wall, ignore horizontal collisions (hack b/c collisions are
    // based on the starting `y` value of the wall which means bots cannot go
    // around field obstacles
    if (wallNum > 3 and (robot.center.y > wallToCheck.end.y or robot.center.y < wallToCheck.start.y)) {
        return false;
    }

    // If bot was originally to the right of the wall
    if (rightX) {
        // Return true if the left edge of the bot is on the left of/on the
        // right edge of the wall
        return (robot.center.x - 10 <= wallToCheck.start.x + 2.5);
    }

    // Else if the bot was originally to the left of the wall
    return (robot.center.x + 10 >= wallToCheck.start.x - 2.5);
}

/// Checks for a vertical collision between a robot and a wall
pub fn checkVerticalCollision(robot: *bot.Robot, wallNum: usize, aboveY: bool) bool {
    const wallToCheck = wall.walls[wallNum];

    // If the wall isn't a field boundary and the robot is not horizontally
    // touching the wall, ignore vertical collisions (hack b/c collisions are
    // based on the starting `x` value of the wall which means bots cannot go
    // around field obstacles
    if (wallNum > 3 and (robot.center.x > wallToCheck.end.x or robot.center.x < wallToCheck.start.x)) {
        return false;
    }
    // If bot was originally below the wall
    if (aboveY) {
        // Return true if the top edge of the bot is above/on the bottom edge of
        // the wall
        return (robot.center.y - 10 <= wallToCheck.start.y + 2.5);
    }

    // Else if the bot was originally above the wall
    return (robot.center.y + 10 >= wallToCheck.start.y - 2.5);
}
