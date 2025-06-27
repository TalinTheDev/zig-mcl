// Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
//! Contains utility functions used in this project

/// Convert an integer (i32) to a float (f32)
pub fn itf(int: i32) f32 {
    return @as(f32, @floatFromInt(int));
}

/// Convert a float (f32) to a integer (i32)
pub fn fti(float: f32) i32 {
    return @as(i32, @intFromFloat(float));
}
