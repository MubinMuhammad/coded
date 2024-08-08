const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "coded",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    const runExe = b.addRunArtifact(exe);

    const runStep = b.step("run", "Run the app");
    runStep.dependOn(&runExe.step);

    const tests = b.addTest(.{
        .root_source_file = b.path("src/tests.zig"),
        .target = target,
        .optimize = optimize,
    });

    const runTest = b.addRunArtifact(tests);

    const runTestStep = b.step("test", "Test the app");
    runTestStep.dependOn(&runTest.step);
}
