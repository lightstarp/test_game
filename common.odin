/*
    このファイルはこのプロジェクトで使う便利なライブラリになる予定です。

    現在（2026/11/09）、命名規則をOdinにあわせたraylibのラッパーを作っています。
    一部の関数はOdinの機能と、あくまでもこのプロジェクトで使うことを考慮してraylibの関数と1対1対応しておらず、
    一部引数や機能が変更されています。
*/

package main

import "vendor:raylib"
import "core:strings"

Vec2      :: raylib.Vector2
Int2      :: [2]i32
Font      :: raylib.Font
Camera_2d :: raylib.Camera2D
Color     :: raylib.Color

init_window :: proc(size: Vec2 = {1280, 720}, title := "Title") {
    title_cstyle := strings.clone_to_cstring(title)
    defer delete(title_cstyle)
    raylib.InitWindow(i32(size.x), i32(size.y), title_cstyle)
}

close_window :: proc() {
    raylib.CloseWindow()
}

load_font :: proc(file_name: string, font_size: i32 = 200, codepoints: [^]rune = nil, codepoint_count: i32 = 0) -> Font {
    file_name_cstyle := strings.clone_to_cstring(file_name)
    defer delete(file_name_cstyle)
    return raylib.LoadFontEx(file_name_cstyle, font_size, codepoints, codepoint_count)
}

unload_font         :: proc(font: Font) { raylib.UnloadFont(font) }
window_should_close :: proc() -> bool   { return raylib.WindowShouldClose() }
set_target_fps      :: proc(fps: i32)   { raylib.SetTargetFPS(fps) }

drawing_begin    :: proc() { raylib.BeginDrawing() }
drawing_end      :: proc() { raylib.EndDrawing() }
clear_background :: proc(color: Color) { raylib.ClearBackground(color) }
draw_triangle    :: proc(p0: Vec2, p1: Vec2, p2: Vec2, c0: Color, c1: Color, c2: Color) {
    raylib.DrawTriangleGradient(p0, p1, p2, c0, c1, c2)
}

mode_begin :: proc(camera: Camera_2d) { raylib.BeginMode2D(camera) }
mode_end   :: proc() { raylib.EndMode2D() }

// size := raylib.MeasureTextEx(custom_font, "hello world", f32(custom_font.baseSize), 0)

// raylib.DrawTextPro(custom_font, "hello world", {0, 0}, size / 2, 0, 50, 0, raylib.WHITE)
