/*
    このファイルはこのプロジェクトで使う便利なライブラリになる予定です。

    現在（2026/11/09）、命名規則をOdinにあわせたraylibのラッパーを作っています。
    一部の関数はOdinの機能と、あくまでもこのプロジェクトで使うことを考慮してraylibの関数と1対1対応しておらず、
    一部引数や機能が変更されています。
*/

package main

import "vendor:raylib"
import "core:math"
import "core:strings"

TAU       :: math.TAU

Vec2       :: raylib.Vector2
Int2       :: [2]i32
Font       :: raylib.Font
Camera_2D  :: raylib.Camera2D
Color      :: raylib.Color
Image      :: raylib.Image
Texture_2D :: raylib.Texture2D

vec_rotate :: proc(v: Vec2, angle: f32) -> Vec2 {
    cn, sn := math.cos(angle), math.sin(angle)

	return Vec2{
		v.x*cn - v.y*sn,
		v.x*sn + v.y*cn,
	}
}

Colors :: struct {
    BLACK    : Color,
    RED      : Color,
    GREEN    : Color,
    YELLOW   : Color,
    BLUE     : Color,
    PURPLE   : Color,
    CYAN     : Color,
    WHITE    : Color,
    GRAY     : Color,
    DARKGRAY : Color,
}

cl := Colors{
    BLACK    = Color{  0,   0,   0, 255},
    RED      = Color{255,   0,   0, 255},
    GREEN    = Color{  0, 255,   0, 255},
    YELLOW   = Color{255, 255,   0, 255},
    BLUE     = Color{  0,   0, 255, 255},
    PURPLE   = Color{255,   0, 255, 255},
    CYAN     = Color{  0, 255, 255, 255},
    WHITE    = Color{255, 255, 255, 255},
    GRAY     = Color{127, 127, 127, 255},
    DARKGRAY = Color{ 30,  30,  30, 255},
}

font: Font

init_window :: proc(size: Vec2 = {1280, 720}, title := "Title") {
    title_cstyle := strings.clone_to_cstring(title)
    defer delete(title_cstyle)
    raylib.InitWindow(i32(size.x), i32(size.y), title_cstyle)
}

close_window        :: proc()         { raylib.CloseWindow() }
window_should_close :: proc() -> bool { return raylib.WindowShouldClose() }
set_target_fps      :: proc(fps: i32) { raylib.SetTargetFPS(fps) }

load_font :: proc(file_name: string, font_size: i32 = 200, codepoints: [^]rune = nil, codepoint_count: i32 = 0) -> Font {
    file_name_c := strings.clone_to_cstring(file_name)
    defer delete(file_name_c)
    return raylib.LoadFontEx(file_name_c, font_size, codepoints, codepoint_count)
}
unload_font :: proc(font: Font) { raylib.UnloadFont(font) }

load_image :: proc(file_name: string) -> Image {
    file_name_c := strings.clone_to_cstring(file_name)
    defer delete(file_name_c)
    return raylib.LoadImage(file_name_c)
}

load_texture :: proc(file_name: string) -> Texture_2D {
    file_name_c := strings.clone_to_cstring(file_name)
    defer delete(file_name_c)
    return raylib.LoadTexture(file_name_c)
}

drawing_begin    :: proc() { raylib.BeginDrawing() }
drawing_end      :: proc() { raylib.EndDrawing() }
clear_background :: proc(color: Color) { raylib.ClearBackground(color) }
draw_triangle    :: proc(p0: Vec2, p1: Vec2, p2: Vec2, c0: Color, c1: Color, c2: Color) {
    raylib.DrawTriangleGradient(p0, p1, p2, c0, c1, c2)
}

draw_quad :: proc(p0: Vec2, p1: Vec2, p2: Vec2, p3: Vec2, c0: Color, c1: Color, c2: Color, c3: Color) {
    raylib.DrawTriangleGradient(p0, p1, p2, c0, c1, c2)
    raylib.DrawTriangleGradient(p2, p3, p0, c2, c3, c0)
}

mode_begin :: proc(camera: Camera_2D) { raylib.BeginMode2D(camera) }
mode_end   :: proc() { raylib.EndMode2D() }

measure_text :: proc(text: string, font_size: f32, space: f32) -> (size: Vec2) {
    text_c := strings.clone_to_cstring(text)
    defer delete(text_c)
    return raylib.MeasureTextEx(font, text_c, font_size, space)
}

draw_text :: proc(text: string, position: Vec2, origin: Vec2, rotation: f32, font_size: f32, space: f32, color: Color) {
    text_c := strings.clone_to_cstring(text)
    defer delete(text_c)
    raylib.DrawTextPro(font, text_c, position, origin, rotation, font_size, space, color)
}

draw_text_center :: proc(text: string, position: Vec2, rotation: f32, font_size: f32, space: f32, color: Color) {
    size := measure_text(text, font_size, space);
    text_c := strings.clone_to_cstring(text)
    defer delete(text_c)
    raylib.DrawTextPro(font, text_c, position, size / 2, rotation, font_size, space, color)
}

draw_texture :: proc(texture: Texture_2D, position: Vec2, rotation: f32, scale: f32, color: Color) {
    raylib.DrawTextureEx(texture, position, rotation, scale, color)
}