const std = @import("std");

pub fn build(b: *std.Build) void {
    const core = b.createModule(.{ .root_source_file = b.path("src/lib/core.zig") });

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "SKYZ",
        .root_source_file = switch (target.result.os.tag) {
            .windows => b.path("src/platform/windows_main.zig"),
            else => unreachable,
        },
        .target = target,
        .optimize = optimize,
        .single_threaded = true,
    });

    exe.root_module.addImport("core", core);
    if (target.result.os.tag == .windows) exe.subsystem = .Windows;
    b.installArtifact(exe);

    const game = b.createModule(.{ .root_source_file = b.path("src/game/game.zig") });
    game.addImport("core", core);
    exe.root_module.addImport("game", game);

    b.step("run", "play game")
        .dependOn(&b.addRunArtifact(exe).step);
}
