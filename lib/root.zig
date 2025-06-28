// Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
//! Project library root

// Imports
const rl = @import("raylib");

// General Re-exports
pub usingnamespace @import("utils.zig");
pub usingnamespace @import("robot.zig");
pub usingnamespace @import("particles.zig");

// Robot Re-Export
const Robot = @import("robot.zig");

// Field Re-export
const Field = @import("field.zig");

pub const field = .{
    .field = Field.field,
    .walls = Field.walls,
};

/// Checks for a collision between a robot and a field wall
pub fn checkFieldCollision(robot: Robot.Robot, wall: Field.FieldWall) bool {
    return rl.checkCollisionCircleLine(robot.center, robot.radius, wall.start, wall.end);
}
