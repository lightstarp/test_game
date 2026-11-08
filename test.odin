package main

import "core:fmt"
import "core:math"
import "vendor:raylib"

width  :: 1280
height :: 720

vec2 :: proc(x: f32, y: f32) -> [2] f32 {
    return [2]f32{x, y}
}

main :: proc() {
    raylib.InitWindow(width, height, "hello world")
    center := vec2(width / 2, height / 2);

    rotate: f32 = 0.0

    raylib.SetTargetFPS(60)

    camera := raylib.Camera2D{
        offset   = center,   
	    target   = vec2(0.0, 0.0),         
	    rotation = 0.0,             
	    zoom     = 1.0,             
    }

    
    for !raylib.WindowShouldClose() {
        
        delta  := raylib.GetFrameTime()
        
        rotate += delta
        
        a := 300 * vec2(math.cos(rotate - math.TAU / 3 * 0), math.sin(rotate - math.TAU / 3 * 0));
        b := 300 * vec2(math.cos(rotate - math.TAU / 3 * 1), math.sin(rotate - math.TAU / 3 * 1));
        c := 300 * vec2(math.cos(rotate - math.TAU / 3 * 2), math.sin(rotate - math.TAU / 3 * 2));
        
        raylib.BeginDrawing()
        raylib.ClearBackground(raylib.DARKGRAY)
        raylib.BeginMode2D(camera)

        raylib.DrawTriangleGradient(a, b, c, raylib.BLUE, raylib.RED, raylib.GREEN)
        raylib.DrawText("hello world", -310, -60, 120, raylib.WHITE)
        
        raylib.EndMode2D()
        raylib.EndDrawing()
        
    }

    raylib.CloseWindow()
}