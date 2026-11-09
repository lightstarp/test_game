package main

import "core:fmt"
import "core:math"
import "vendor:raylib"

width  :: 1280
height :: 720

main :: proc() {
    init_window({width, height}, "hello world")
    font     = load_font("RobotoMono-SemiBold.ttf", 80)
    texture := load_texture("hello.png")
    set_target_fps(60)

    rotate: f32 = 0.0

    camera := Camera_2D{
        offset   = {width, height} / 2,
	    target   = {0.0, 0.0},         
	    rotation = 0.0,             
	    zoom     = 1.0,             
    }

    entities_pos: [] Vec2 = {
        {-500, -500},
        {   0, -500},
        { 500, -500},
        {-500,    0},
        {   0,    0},
        { 500,    0},
        {-500,  500},
        {   0,  500},
        { 500,  500},
    }
    
    for !window_should_close() {
        delta  := raylib.GetFrameTime()
        rotate += delta
        
        
        drawing_begin()
        clear_background(cl.DARKGRAY)
        mode_begin(camera)
        
        // /* ここからメインのレンダリング */
        p0 := vec_rotate({0, 250}, rotate - TAU / 4 * 0)
        p1 := vec_rotate({0, 250}, rotate - TAU / 4 * 1)
        p2 := vec_rotate({0, 250}, rotate - TAU / 4 * 2)
        p3 := vec_rotate({0, 250}, rotate - TAU / 4 * 3)

        for entity_pos in entities_pos {
            draw_quad(
                entity_pos + p0, entity_pos + p1, entity_pos + p2, entity_pos + p3,
                cl.RED, cl.YELLOW, cl.GREEN, cl.BLUE
            )
        }
        
        draw_text_center("raylib", {0, 0}, 0, 80, 0, cl.WHITE)
        // /* レンダリング終わり */
        
        mode_end()
        drawing_end()
    }

    unload_font(font)
    close_window()
}