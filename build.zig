// Copyright 2025 Talin Sharma. Subject to the Apache-2.0 license.
//! Build instructions for this project

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_mod = b.createModule(.{
        .root_source_file = b.path("lib/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe_mod.addImport("zig_mcl_lib", lib_mod);

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "zig_mcl_lib",
        .root_module = lib_mod,
    });

    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "zig_mcl",
        .root_module = exe_mod,
    });

    // Add Raylib Bindings
    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
        .linux_display_backend = .Wayland,
    });
    const raylib = raylib_dep.module("raylib"); // main raylib module
    const raygui = raylib_dep.module("raygui"); // raygui module
    const raylib_artifact = raylib_dep.artifact("raylib"); // raylib C library

    exe.linkLibrary(raylib_artifact);
    exe.root_module.addImport("raylib", raylib);
    exe.root_module.addImport("raygui", raygui);

    lib.linkLibrary(raylib_artifact);
    lib.root_module.addImport("raylib", raylib);
    lib.root_module.addImport("raygui", raygui);

    const zprob_dep = b.dependency("zprob", .{
        .target = target,
        .optimize = optimize,
    });

    const zprob_module = zprob_dep.module("zprob");
    exe.root_module.addImport("zprob", zprob_module);
    lib.root_module.addImport("zprob", zprob_module);

    b.installDirectory(.{
        .source_dir = .{ .cwd_relative = "assets" },
        .install_dir = .bin,
        .install_subdir = "assets",
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const lib_unit_tests = b.addTest(.{
        .root_module = lib_mod,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
