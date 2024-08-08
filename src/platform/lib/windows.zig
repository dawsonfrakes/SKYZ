const core = @import("core");
pub const WINAPI: core.CallingConvention =
    if (core.cpu_arch == .x86) .Stdcall else .C;

pub const kernel32 = struct {
    pub const HINSTANCE = *opaque {};
    pub const HMODULE = HINSTANCE;
    pub const PROC = *const fn () callconv(WINAPI) isize;

    pub extern "kernel32" fn GetModuleHandleW(?[*:0]const u16) callconv(WINAPI) ?HMODULE;
    pub extern "kernel32" fn Sleep(c_ulong) callconv(WINAPI) void;
    pub extern "kernel32" fn ExitProcess(c_uint) callconv(WINAPI) noreturn;
};

pub const user32 = struct {
    pub const IDI_WARNING: *anyopaque = @ptrFromInt(32515);
    pub const IDC_CROSS: *anyopaque = @ptrFromInt(32515);
    pub const CS_OWNDC = 0x0020;
    pub const WS_MAXIMIZEBOX = 0x00010000;
    pub const WS_MINIMIZEBOX = 0x00020000;
    pub const WS_THICKFRAME = 0x00040000;
    pub const WS_SYSMENU = 0x00080000;
    pub const WS_CAPTION = 0x00C00000;
    pub const WS_VISIBLE = 0x10000000;
    pub const WS_OVERLAPPEDWINDOW = WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX;
    pub const CW_USEDEFAULT: c_int = @bitCast(@as(c_uint, 0x80000000));
    pub const PM_REMOVE = 0x0001;
    pub const WM_CREATE = 0x0001;
    pub const WM_DESTROY = 0x0002;
    pub const WM_SIZE = 0x0005;
    pub const WM_PAINT = 0x000F;
    pub const WM_QUIT = 0x0012;
    pub const WM_ERASEBKGND = 0x0014;
    pub const WM_ACTIVATEAPP = 0x001C;
    pub const WM_KEYDOWN = 0x0100;
    pub const WM_KEYUP = 0x0101;
    pub const WM_SYSKEYDOWN = 0x0104;
    pub const WM_SYSKEYUP = 0x0105;
    pub const WM_SYSCOMMAND = 0x0112;
    pub const SC_KEYMENU = 0xF100;
    pub const GWL_STYLE = -16;
    pub const HWND_TOP: ?HWND = @ptrFromInt(0);
    pub const SWP_NOSIZE = 0x0001;
    pub const SWP_NOMOVE = 0x0002;
    pub const SWP_NOZORDER = 0x0004;
    pub const SWP_FRAMECHANGED = 0x0020;
    pub const MONITOR_DEFAULTTOPRIMARY = 0x00000001;
    pub const VK_RETURN = 0x0D;
    pub const VK_ESCAPE = 0x1B;
    pub const VK_F4 = 0x73;
    pub const VK_F10 = 0x79;
    pub const VK_F11 = 0x7A;

    pub const HDC = *opaque {};
    pub const HWND = *opaque {};
    pub const HMENU = *opaque {};
    pub const HICON = *opaque {};
    pub const HBRUSH = *opaque {};
    pub const HCURSOR = *opaque {};
    pub const HMONITOR = *opaque {};
    pub const WNDPROC = *const fn (?HWND, c_uint, usize, isize) callconv(WINAPI) isize;
    pub const POINT = extern struct {
        x: c_long,
        y: c_long,
    };
    pub const RECT = extern struct {
        left: c_long,
        top: c_long,
        right: c_long,
        bottom: c_long,
    };
    pub const WNDCLASSEXW = extern struct {
        cbSize: c_uint,
        style: c_uint,
        lpfnWndProc: ?WNDPROC,
        cbClsExtra: c_int,
        cbWndExtra: c_int,
        hInstance: ?kernel32.HINSTANCE,
        hIcon: ?HICON,
        hCursor: ?HCURSOR,
        hbrBackground: ?HBRUSH,
        lpszMenuName: ?[*:0]const u16,
        lpszClassName: ?[*:0]const u16,
        hIconSm: ?HICON,
    };
    pub const MSG = extern struct {
        hwnd: ?HWND,
        message: c_uint,
        wParam: usize,
        lParam: isize,
        time: c_ulong,
        pt: POINT,
        lPrivate: c_ulong,
    };
    pub const WINDOWPLACEMENT = extern struct {
        length: c_uint,
        flags: c_uint,
        showCmd: c_uint,
        ptMinPosition: POINT,
        ptMaxPosition: POINT,
        rcNormalPosition: RECT,
        rcDevice: RECT,
    };
    pub const MONITORINFO = extern struct {
        cbSize: c_ulong,
        rcMonitor: RECT,
        rcWork: RECT,
        dwFlags: c_ulong,
    };

    pub extern "user32" fn LoadIconW(?kernel32.HINSTANCE, ?[*:0]align(1) const u16) callconv(WINAPI) ?HICON;
    pub extern "user32" fn LoadCursorW(?kernel32.HINSTANCE, ?[*:0]align(1) const u16) callconv(WINAPI) ?HCURSOR;
    pub extern "user32" fn SetProcessDPIAware() callconv(WINAPI) c_int;
    pub extern "user32" fn RegisterClassExW(?*const WNDCLASSEXW) callconv(WINAPI) c_ushort;
    pub extern "user32" fn CreateWindowExW(c_ulong, ?[*:0]const u16, ?[*:0]const u16, c_ulong, c_int, c_int, c_int, c_int, ?HWND, ?HMENU, ?kernel32.HINSTANCE, ?*anyopaque) callconv(WINAPI) ?HWND;
    pub extern "user32" fn PeekMessageW(?*MSG, ?HWND, c_uint, c_uint, c_uint) callconv(WINAPI) c_int;
    pub extern "user32" fn TranslateMessage(?*const MSG) callconv(WINAPI) c_int;
    pub extern "user32" fn DispatchMessageW(?*const MSG) callconv(WINAPI) isize;
    pub extern "user32" fn DefWindowProcW(?HWND, c_uint, usize, isize) callconv(WINAPI) isize;
    pub extern "user32" fn PostQuitMessage(c_int) callconv(WINAPI) void;
    pub extern "user32" fn GetDC(?HWND) callconv(WINAPI) ?HDC;
    pub extern "user32" fn ValidateRect(?HWND, ?*const RECT) callconv(WINAPI) c_int;
    pub extern "user32" fn DestroyWindow(?HWND) callconv(WINAPI) c_int;
    pub extern "user32" fn GetWindowLongPtrW(?HWND, c_int) callconv(WINAPI) isize;
    pub extern "user32" fn SetWindowLongPtrW(?HWND, c_int, isize) callconv(WINAPI) isize;
    pub extern "user32" fn GetWindowPlacement(?HWND, ?*WINDOWPLACEMENT) callconv(WINAPI) c_int;
    pub extern "user32" fn SetWindowPlacement(?HWND, ?*const WINDOWPLACEMENT) callconv(WINAPI) c_int;
    pub extern "user32" fn SetWindowPos(?HWND, ?HWND, c_int, c_int, c_int, c_int, c_uint) callconv(WINAPI) c_int;
    pub extern "user32" fn ShowCursor(c_int) callconv(WINAPI) c_int;
    pub extern "user32" fn ClipCursor(?*const RECT) callconv(WINAPI) c_int;
    pub extern "user32" fn MonitorFromWindow(?HWND, c_ulong) callconv(WINAPI) ?HMONITOR;
    pub extern "user32" fn GetMonitorInfoW(?HMONITOR, ?*MONITORINFO) callconv(WINAPI) c_int;
};

pub const gdi32 = struct {
    pub const PFD_DOUBLEBUFFER = 0x00000001;
    pub const PFD_DRAW_TO_WINDOW = 0x00000004;
    pub const PFD_SUPPORT_OPENGL = 0x00000020;
    pub const PFD_DEPTH_DONTCARE = 0x20000000;

    pub const PIXELFORMATDESCRIPTOR = extern struct {
        nSize: c_ushort,
        nVersion: c_ushort,
        dwFlags: c_ulong,
        iPixelType: u8,
        cColorBits: u8,
        cRedBits: u8,
        cRedShift: u8,
        cGreenBits: u8,
        cGreenShift: u8,
        cBlueBits: u8,
        cBlueShift: u8,
        cAlphaBits: u8,
        cAlphaShift: u8,
        cAccumBits: u8,
        cAccumRedBits: u8,
        cAccumGreenBits: u8,
        cAccumBlueBits: u8,
        cAccumAlphaBits: u8,
        cDepthBits: u8,
        cStencilBits: u8,
        cAuxBuffers: u8,
        iLayerType: u8,
        bReserved: u8,
        dwLayerMask: c_ulong,
        dwVisibleMask: c_ulong,
        dwDamageMask: c_ulong,
    };

    pub extern "gdi32" fn ChoosePixelFormat(?user32.HDC, ?*const PIXELFORMATDESCRIPTOR) callconv(WINAPI) c_int;
    pub extern "gdi32" fn SetPixelFormat(?user32.HDC, c_int, ?*const PIXELFORMATDESCRIPTOR) callconv(WINAPI) c_int;
    pub extern "gdi32" fn SwapBuffers(?user32.HDC) callconv(WINAPI) c_int;
};

pub const opengl32 = struct {
    pub const WGL_CONTEXT_MAJOR_VERSION_ARB = 0x2091;
    pub const WGL_CONTEXT_MINOR_VERSION_ARB = 0x2092;
    pub const WGL_CONTEXT_FLAGS_ARB = 0x2094;
    pub const WGL_CONTEXT_PROFILE_MASK_ARB = 0x9126;
    pub const WGL_CONTEXT_DEBUG_BIT_ARB = 0x0001;
    pub const WGL_CONTEXT_CORE_PROFILE_BIT_ARB = 0x00000001;

    pub const HGLRC = *opaque {};
    pub const PFN_wglCreateContextAttribsARB = *const fn (?user32.HDC, ?HGLRC, ?[*:0]const c_int) callconv(WINAPI) ?HGLRC;

    pub extern "opengl32" fn wglCreateContext(?user32.HDC) callconv(WINAPI) ?HGLRC;
    pub extern "opengl32" fn wglDeleteContext(?HGLRC) callconv(WINAPI) c_int;
    pub extern "opengl32" fn wglMakeCurrent(?user32.HDC, ?HGLRC) callconv(WINAPI) c_int;
    pub extern "opengl32" fn wglGetProcAddress(?[*:0]const u8) callconv(WINAPI) ?kernel32.PROC;

    pub extern "opengl32" fn glEnable(u32) callconv(WINAPI) void;
    pub extern "opengl32" fn glDisable(u32) callconv(WINAPI) void;
    pub extern "opengl32" fn glGetIntegerv(u32, ?[*]i32) callconv(WINAPI) void;
    pub extern "opengl32" fn glDepthFunc(u32) callconv(WINAPI) void;
    pub extern "opengl32" fn glBlendFunc(u32, u32) callconv(WINAPI) void;
    pub extern "opengl32" fn glViewport(i32, i32, u32, u32) callconv(WINAPI) void;
    pub extern "opengl32" fn glClear(u32) callconv(WINAPI) void;
};

pub const dwmapi = struct {
    pub const DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
    pub const DWMWA_WINDOW_CORNER_PREFERENCE = 33;
    pub const DWMWCP_DONOTROUND = 1;

    pub extern "dwmapi" fn DwmSetWindowAttribute(?user32.HWND, c_ulong, ?*const anyopaque, c_ulong) callconv(WINAPI) c_long;
};

pub const winmm = struct {
    pub extern "winmm" fn timeBeginPeriod(c_uint) callconv(WINAPI) c_uint;
};
