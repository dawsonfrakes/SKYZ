const core = @import("core");

pub const GLAPI: core.CallingConvention =
    if (core.os_tag == .windows and core.cpu_arch == .x86) .Stdcall else .C;

pub const gl10 = struct {
    pub const GL_COLOR_BUFFER_BIT = 0x00004000;
    pub const GL_TRIANGLES = 0x0004;
    pub const GL_GEQUAL = 0x0206;
    pub const GL_SRC_ALPHA = 0x0302;
    pub const GL_ONE_MINUS_SRC_ALPHA = 0x0303;
    pub const GL_FRONT_AND_BACK = 0x0408;
    pub const GL_CULL_FACE = 0x0B44;
    pub const GL_DEPTH_TEST = 0x0B71;
    pub const GL_BLEND = 0x0BE2;
    pub const GL_TEXTURE_2D = 0x0DE1;
    pub const GL_BYTE = 0x1400;
    pub const GL_UNSIGNED_BYTE = 0x1401;
    pub const GL_SHORT = 0x1402;
    pub const GL_UNSIGNED_SHORT = 0x1403;
    pub const GL_INT = 0x1404;
    pub const GL_UNSIGNED_INT = 0x1405;
    pub const GL_FLOAT = 0x1406;
    pub const GL_COLOR = 0x1800;
    pub const GL_DEPTH = 0x1801;
    pub const GL_ALPHA = 0x1906;
    pub const GL_RGB = 0x1907;
    pub const GL_RGBA = 0x1908;
    pub const GL_POINT = 0x1B00;
    pub const GL_LINE = 0x1B01;
    pub const GL_FILL = 0x1B02;
    pub const GL_NEAREST = 0x2600;
    pub const GL_LINEAR = 0x2601;
    pub const GL_NEAREST_MIPMAP_NEAREST = 0x2700;
    pub const GL_LINEAR_MIPMAP_NEAREST = 0x2701;
    pub const GL_NEAREST_MIPMAP_LINEAR = 0x2702;
    pub const GL_LINEAR_MIPMAP_LINEAR = 0x2703;
    pub const GL_TEXTURE_MAG_FILTER = 0x2800;
    pub const GL_TEXTURE_MIN_FILTER = 0x2801;
    pub const GL_TEXTURE_WRAP_S = 0x2802;
    pub const GL_TEXTURE_WRAP_T = 0x2803;
    pub const GL_REPEAT = 0x2901;

    pub extern fn glEnable(u32) callconv(GLAPI) void;
    pub extern fn glDisable(u32) callconv(GLAPI) void;
    pub extern fn glGetIntegerv(u32, ?[*]i32) callconv(GLAPI) void;
    pub extern fn glDepthFunc(u32) callconv(GLAPI) void;
    pub extern fn glBlendFunc(u32, u32) callconv(GLAPI) void;
    pub extern fn glViewport(i32, i32, u32, u32) callconv(GLAPI) void;
    pub extern fn glClear(u32) callconv(GLAPI) void;
};

pub const gl15 = struct {};

pub const gl20 = struct {};

pub const gl30 = struct {
    pub const GL_RGBA16F = 0x881A;
    pub const GL_DEPTH_COMPONENT32F = 0x8CAC;
    pub const GL_COLOR_ATTACHMENT0 = 0x8CE0;
    pub const GL_DEPTH_ATTACHMENT = 0x8D00;
    pub const GL_FRAMEBUFFER = 0x8D40;
    pub const GL_RENDERBUFFER = 0x8D41;
    pub const GL_FRAMEBUFFER_SRGB = 0x8DB9;

    pub extern fn glBindFramebuffer(u32, u32) callconv(GLAPI) void;
    pub extern fn glBindVertexArray(u32) callconv(GLAPI) void;
};

pub const gl32 = struct {
    pub const GL_MAX_COLOR_TEXTURE_SAMPLES = 0x910E;
    pub const GL_MAX_DEPTH_TEXTURE_SAMPLES = 0x910F;
};

pub const gl42 = struct {};

pub const gl43 = struct {};

pub const gl45 = struct {
    pub extern fn glCreateFramebuffers(u32, ?[*]u32) callconv(GLAPI) void;
    pub extern fn glNamedFramebufferRenderbuffer(u32, u32, u32, u32) callconv(GLAPI) void;
    pub extern fn glClearNamedFramebufferfv(u32, u32, i32, ?[*]const f32) callconv(GLAPI) void;
    pub extern fn glBlitNamedFramebuffer(u32, u32, i32, i32, i32, i32, i32, i32, i32, i32, u32, u32) callconv(GLAPI) void;
    pub extern fn glCreateRenderbuffers(u32, ?[*]u32) callconv(GLAPI) void;
    pub extern fn glNamedRenderbufferStorageMultisample(u32, u32, u32, u32, u32) callconv(GLAPI) void;
    pub extern fn glCreateVertexArrays(u32, ?[*]u32) callconv(GLAPI) void;
    pub extern fn glCreateBuffers(u32, ?[*]u32) callconv(GLAPI) void;
    pub extern fn glCreateTextures(u32, u32, ?[*]u32) callconv(GLAPI) void;
};
