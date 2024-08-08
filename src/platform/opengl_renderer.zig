const core = @import("core");
const game = @import("game");
var gl: core.FnsToFnPtrs(struct {
    const opengl = @import("lib/opengl.zig");
    pub usingnamespace opengl;
    pub usingnamespace opengl.gl10;
    pub usingnamespace opengl.gl15;
    pub usingnamespace opengl.gl20;
    pub usingnamespace opengl.gl30;
    pub usingnamespace opengl.gl32;
    pub usingnamespace opengl.gl42;
    pub usingnamespace opengl.gl43;
    pub usingnamespace opengl.gl45;
}) = undefined;
const platform = struct {
    usingnamespace @import("root").platform;
    usingnamespace switch (core.os_tag) {
        .windows => struct {
            const w = struct {
                const windows = @import("lib/windows.zig");
                usingnamespace windows;
                usingnamespace windows.gdi32;
                usingnamespace windows.opengl32;
            };
            var ctx: ?w.HGLRC = null;

            fn init() !void {
                const pfd = core.zeroInit(w.PIXELFORMATDESCRIPTOR, .{
                    .nSize = @sizeOf(w.PIXELFORMATDESCRIPTOR),
                    .nVersion = 1,
                    .dwFlags = w.PFD_DRAW_TO_WINDOW | w.PFD_SUPPORT_OPENGL |
                        w.PFD_DOUBLEBUFFER | w.PFD_DEPTH_DONTCARE,
                    .cColorBits = 24,
                });
                const format = w.ChoosePixelFormat(platform.hdc, &pfd);
                _ = w.SetPixelFormat(platform.hdc, format, &pfd);

                const temp_ctx = w.wglCreateContext(platform.hdc) orelse
                    return error.ContextCreation;
                defer _ = w.wglDeleteContext(temp_ctx);
                _ = w.wglMakeCurrent(platform.hdc, temp_ctx);

                const wglCreateContextAttribsARB: w.PFN_wglCreateContextAttribsARB =
                    @ptrCast(w.wglGetProcAddress("wglCreateContextAttribsARB") orelse
                    return error.FunctionLoading);

                const flags = if (core.build_mode == .Debug) w.WGL_CONTEXT_DEBUG_BIT_ARB else 0;
                const attribs = [_:0]c_int{
                    w.WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
                    w.WGL_CONTEXT_MINOR_VERSION_ARB, 6,
                    w.WGL_CONTEXT_FLAGS_ARB,         flags,
                    w.WGL_CONTEXT_PROFILE_MASK_ARB,  w.WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
                };
                ctx = wglCreateContextAttribsARB(platform.hdc, null, &attribs) orelse
                    return error.ContextCreation;
                _ = w.wglMakeCurrent(platform.hdc, ctx);

                inline for (@typeInfo(@TypeOf(gl)).Struct.fields) |field| {
                    if (!field.is_comptime) {
                        @field(gl, field.name) = if (@hasDecl(w, field.name))
                            @field(w, field.name)
                        else
                            @ptrCast(w.wglGetProcAddress(field.name) orelse
                                return error.FunctionLoading);
                    }
                }
            }

            fn deinit() void {
                if (ctx != null) _ = w.wglDeleteContext(ctx);
                ctx = null;
            }

            fn present() void {
                _ = w.SwapBuffers(platform.hdc);
            }
        },
        else => |tag| @compileError("no opengl on " ++ tag),
    };
};

var main_fbo: u32 = undefined;
var main_fbo_color0: u32 = undefined;
var main_fbo_depth: u32 = undefined;

pub fn init() !void {
    try platform.init();

    gl.glCreateFramebuffers(1, @ptrCast(&main_fbo));
    gl.glCreateRenderbuffers(1, @ptrCast(&main_fbo_color0));
    gl.glCreateRenderbuffers(1, @ptrCast(&main_fbo_depth));
}

pub fn deinit() void {
    platform.deinit();
}

pub fn resize() void {
    var fbo_color_samples_max: i32 = undefined;
    gl.glGetIntegerv(gl.GL_MAX_COLOR_TEXTURE_SAMPLES, @ptrCast(&fbo_color_samples_max));
    var fbo_depth_samples_max: i32 = undefined;
    gl.glGetIntegerv(gl.GL_MAX_DEPTH_TEXTURE_SAMPLES, @ptrCast(&fbo_depth_samples_max));
    const fbo_samples: u32 = @intCast(@min(fbo_color_samples_max, fbo_depth_samples_max));

    gl.glNamedRenderbufferStorageMultisample(
        main_fbo_color0,
        fbo_samples,
        gl.GL_RGBA16F,
        platform.screen_width,
        platform.screen_height,
    );
    gl.glNamedFramebufferRenderbuffer(
        main_fbo,
        gl.GL_COLOR_ATTACHMENT0,
        gl.GL_RENDERBUFFER,
        main_fbo_color0,
    );

    gl.glNamedRenderbufferStorageMultisample(
        main_fbo_depth,
        fbo_samples,
        gl.GL_DEPTH_COMPONENT32F,
        platform.screen_width,
        platform.screen_height,
    );
    gl.glNamedFramebufferRenderbuffer(
        main_fbo,
        gl.GL_DEPTH_ATTACHMENT,
        gl.GL_RENDERBUFFER,
        main_fbo_depth,
    );
}

pub fn present(render_commands: []const game.render.Command) void {
    gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, main_fbo);

    for (render_commands) |command| {
        switch (command) {
            .clear => |color| {
                gl.glClearNamedFramebufferfv(main_fbo, gl.GL_COLOR, 0, &@as([4]f32, color));
                gl.glClearNamedFramebufferfv(main_fbo, gl.GL_DEPTH, 0, &.{0.0});
            },
            .mesh => |mesh| {
                _ = @intFromEnum(mesh.kind);
            },
        }
    }

    // note(dfra): fixes intel default framebuffer resize bug
    gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, 0);
    gl.glClear(0);

    gl.glEnable(gl.GL_FRAMEBUFFER_SRGB);
    gl.glBlitNamedFramebuffer(
        main_fbo,
        0,
        0,
        0,
        platform.screen_width,
        platform.screen_height,
        0,
        0,
        platform.screen_width,
        platform.screen_height,
        gl.GL_COLOR_BUFFER_BIT,
        gl.GL_NEAREST,
    );
    gl.glDisable(gl.GL_FRAMEBUFFER_SRGB);

    platform.present();
}
