const core = @import("core");

pub const math = struct {
    pub const v2 = @Vector(2, f32);
    pub const v3 = @Vector(3, f32);
    pub const v4 = @Vector(4, f32);
    pub const m4 = @Vector(16, f32);
    pub const Transform = struct {
        position: v3,
        rotation: v3,
        scale: v3,

        // pub fn toMatrix(self: @This()) m4 {}
    };
};

pub const render = struct {
    pub const MeshKind = enum {
        triangle,
        square,
    };
    pub const CommandKind = enum {
        clear,
        mesh,
    };
    pub const Command = union(CommandKind) {
        clear: math.v4,
        mesh: struct {
            kind: MeshKind,
            transform: math.Transform,
            entity_id: u32,
        },
    };
    pub const Renderer = struct {
        commands: core.BoundedArray(render.Command, 1024) = .{},

        pub fn clear(self: *@This(), color: math.v4) void {
            self.commands.append(.{ .clear = color }) catch {};
        }
    };
};

pub fn update(renderer: *render.Renderer) callconv(.C) void {
    renderer.clear(.{ 0.6, 0.2, 0.2, 1.0 });
}
