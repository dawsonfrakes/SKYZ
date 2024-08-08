const core = @import("core");
const w = struct {
    const windows = @import("lib/windows.zig");
    usingnamespace windows;
    usingnamespace windows.kernel32;
    usingnamespace windows.user32;
    usingnamespace windows.dwmapi;
    usingnamespace windows.winmm;
};
pub const platform = struct {
    pub var screen_width: u16 = undefined;
    pub var screen_height: u16 = undefined;
    pub var hinstance: w.HINSTANCE = undefined;
    pub var hwnd: w.HWND = undefined;
    pub var hdc: w.HDC = undefined;
};
const render_api = @import("opengl_renderer.zig");

fn updateCursorClip() void {
    var i = w.ShowCursor(0);
    while (i < 0) : (i += 1) _ = w.ShowCursor(1);
    _ = w.ClipCursor(null);
}

fn toggleFullscreen() void {
    const S = struct {
        var save_placement = core.zeroInit(w.WINDOWPLACEMENT, .{
            .length = @sizeOf(w.WINDOWPLACEMENT),
        });
    };

    const style = w.GetWindowLongPtrW(platform.hwnd, w.GWL_STYLE);
    if (style & w.WS_OVERLAPPEDWINDOW != 0) {
        var mi = core.zeroInit(w.MONITORINFO, .{ .cbSize = @sizeOf(w.MONITORINFO) });
        _ = w.GetMonitorInfoW(
            w.MonitorFromWindow(platform.hwnd, w.MONITOR_DEFAULTTOPRIMARY),
            &mi,
        );

        _ = w.GetWindowPlacement(platform.hwnd, &S.save_placement);
        _ = w.SetWindowLongPtrW(platform.hwnd, w.GWL_STYLE, style & ~@as(isize, w.WS_OVERLAPPEDWINDOW));
        _ = w.SetWindowPos(
            platform.hwnd,
            w.HWND_TOP,
            mi.rcMonitor.left,
            mi.rcMonitor.top,
            mi.rcMonitor.right - mi.rcMonitor.left,
            mi.rcMonitor.bottom - mi.rcMonitor.top,
            w.SWP_FRAMECHANGED,
        );
    } else {
        _ = w.SetWindowLongPtrW(platform.hwnd, w.GWL_STYLE, style | w.WS_OVERLAPPEDWINDOW);
        _ = w.SetWindowPlacement(platform.hwnd, &S.save_placement);
        _ = w.SetWindowPos(platform.hwnd, null, 0, 0, 0, 0, w.SWP_NOSIZE |
            w.SWP_NOMOVE | w.SWP_NOZORDER | w.SWP_FRAMECHANGED);
    }
}

fn windowProc(hwnd: ?w.HWND, message: c_uint, wParam: usize, lParam: isize) callconv(w.WINAPI) isize {
    @setAlignStack(16);
    switch (message) {
        w.WM_PAINT => _ = w.ValidateRect(hwnd, null),
        w.WM_ERASEBKGND => return 1,
        w.WM_ACTIVATEAPP => {
            if (wParam != 0) updateCursorClip();
        },
        w.WM_SIZE => {
            platform.screen_width = @truncate(@as(usize, @bitCast(lParam)));
            platform.screen_height = @truncate(@as(usize, @bitCast(lParam)) >> 16);

            render_api.resize();
        },
        w.WM_CREATE => {
            platform.hwnd = hwnd.?;
            platform.hdc = w.GetDC(hwnd).?;

            const dark_mode: c_int = 1;
            _ = w.DwmSetWindowAttribute(hwnd, w.DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, @sizeOf(c_int));
            const round_mode: c_int = w.DWMWCP_DONOTROUND;
            _ = w.DwmSetWindowAttribute(hwnd, w.DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, @sizeOf(c_int));

            render_api.init() catch @panic("renderer.init");
        },
        w.WM_DESTROY => {
            render_api.deinit();

            w.PostQuitMessage(0);
        },
        else => {
            if (!(message == w.WM_SYSCOMMAND and wParam == w.SC_KEYMENU))
                return w.DefWindowProcW(hwnd, message, wParam, lParam);
        },
    }
    return 0;
}

pub export fn wWinMainCRTStartup() callconv(w.WINAPI) noreturn {
    @setAlignStack(16);
    platform.hinstance = w.GetModuleHandleW(null).?;

    const sleep_is_granular = w.timeBeginPeriod(1) == 0;

    _ = w.SetProcessDPIAware();
    const wndclass = core.zeroInit(w.WNDCLASSEXW, .{
        .cbSize = @sizeOf(w.WNDCLASSEXW),
        .style = w.CS_OWNDC,
        .lpfnWndProc = windowProc,
        .hInstance = platform.hinstance,
        .hIcon = w.LoadIconW(null, @ptrCast(w.IDI_WARNING)).?,
        .hCursor = w.LoadCursorW(null, @ptrCast(w.IDC_CROSS)).?,
        .lpszClassName = core.asciiToUtf16LeStringLiteral("A"),
    });
    _ = w.RegisterClassExW(&wndclass);
    _ = w.CreateWindowExW(
        0,
        wndclass.lpszClassName,
        core.asciiToUtf16LeStringLiteral("SKYZ"),
        w.WS_OVERLAPPEDWINDOW | w.WS_VISIBLE,
        w.CW_USEDEFAULT,
        w.CW_USEDEFAULT,
        w.CW_USEDEFAULT,
        w.CW_USEDEFAULT,
        null,
        null,
        platform.hinstance,
        null,
    );

    const game = @import("game");

    var renderer = game.render.Renderer{};

    game_loop: while (true) {
        var msg: w.MSG = undefined;
        while (w.PeekMessageW(&msg, null, 0, 0, w.PM_REMOVE) != 0) {
            _ = w.TranslateMessage(&msg);
            switch (msg.message) {
                w.WM_KEYDOWN, w.WM_KEYUP, w.WM_SYSKEYDOWN, w.WM_SYSKEYUP => {
                    const pressed = msg.lParam & 1 << 31 == 0;
                    const repeat = pressed and msg.lParam & 1 << 30 != 0;
                    const sys = msg.message == w.WM_SYSKEYDOWN or msg.message == w.WM_SYSKEYUP;
                    const alt = sys and msg.lParam & 1 << 29 != 0;

                    if (!repeat and (!sys or alt or msg.wParam == w.VK_F10)) {
                        if (pressed) {
                            if (msg.wParam == w.VK_F4 and alt) _ = w.DestroyWindow(platform.hwnd);
                            if (msg.wParam == w.VK_F11 or (msg.wParam == w.VK_RETURN and alt))
                                toggleFullscreen();
                            if (core.build_mode == .Debug and msg.wParam == w.VK_ESCAPE)
                                _ = w.DestroyWindow(platform.hwnd);
                        }
                    }
                },
                w.WM_QUIT => break :game_loop,
                else => _ = w.DispatchMessageW(&msg),
            }
        }

        game.update(&renderer);

        render_api.present(renderer.commands.constSlice());
        renderer.commands.clear();

        if (sleep_is_granular) {
            w.Sleep(1);
        }
    }

    w.ExitProcess(0);
}
