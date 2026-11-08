package main

import "core:fmt"
import "core:math"
import "vendor:raylib"

width  :: 1280
height :: 720

main :: proc() {
    init_window({width, height}, "hello world")
    center := Vec2{width / 2, height / 2}
    custom_font := load_font("RobotoMono-SemiBold.ttf", 50)
    // custom_font := raylib.LoadFont("RobotoMono-SemiBold.ttf")


    rotate: f32 = 0.0

    set_target_fps(60)

    camera := Camera_2d{
        offset   = center,   
	    target   = {0.0, 0.0},         
	    rotation = 0.0,             
	    zoom     = 1.0,             
    }

    
    for !window_should_close() {
        delta  := raylib.GetFrameTime()
        
        rotate += delta
        
        a := 300 * Vec2{math.cos(rotate - math.TAU / 3 * 0), math.sin(rotate - math.TAU / 3 * 0)};
        b := 300 * Vec2{math.cos(rotate - math.TAU / 3 * 1), math.sin(rotate - math.TAU / 3 * 1)};
        c := 300 * Vec2{math.cos(rotate - math.TAU / 3 * 2), math.sin(rotate - math.TAU / 3 * 2)};
        
        drawing_begin()
        raylib.ClearBackground(raylib.DARKGRAY)
        raylib.BeginMode2D(camera)

        size := raylib.MeasureTextEx(custom_font, "hello world", f32(custom_font.baseSize), 0)

        raylib.DrawTriangleGradient(a, b, c, raylib.BLUE, raylib.RED, raylib.GREEN)
        raylib.DrawTextPro(custom_font, "hello world", {0, 0}, size / 2, 0, 50, 0, raylib.WHITE)
        
        mode_end()
        drawing_end()
    }

    raylib.UnloadFont(custom_font);
    raylib.CloseWindow()
}