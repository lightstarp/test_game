package main

import "core:fmt"
import "core:os"
import "core:math"
import "vendor:raylib"



world_size  :: Vec2{16 *  8, 12 *  8}
screen_size :: Vec2{16 * 60, 12 * 60}

cos_and_sin_field : [64]Vec2

world_pos_to_screen :: proc(pos: Vec2) -> Vec2 {
    return Vec2{
          pos.x / world_size.x      * screen_size.x,
        (-pos.y / world_size.y + 1) * screen_size.y,
    }
}

screen_pos_to_world :: proc(pos: Vec2) -> Vec2 {
    return Vec2{
          pos.x / screen_size.x      * world_size.x,
        -(pos.y / screen_size.y - 1) * world_size.y,
    }
}

distance :: proc(v: Vec2) -> f32 {
    return math.sqrt(v.x * v.x + v.y * v.y)
}

normalize :: proc(v: Vec2, value: f32 = 1) -> Vec2 {
    return v / distance(v) * value
}

intersection :: proc(p0, p1, p2, p3: Vec2) -> Vec2 {
    det :=  (p0.x - p1.x) * (p3.y - p2.y) - (p3.x - p2.x) * (p0.y - p1.y)
    t   := ((p3.y - p2.y) * (p3.x - p1.x) + (p2.x - p3.x) * (p3.y - p1.y)) / det
    x   := t * p0.x + (1.0 - t) * p1.x
    y   := t * p0.y + (1.0 - t) * p1.y
    return {x, y}
}

Player :: struct {
    pos:    Vec2,
    vel:    Vec2,
    rotate: Vec2,
    bullet_cool_time: u32,
}

mouse_pos: Vec2

player := Player{
    pos    = {10, 10},
    vel    = { 0,  0},
    rotate = { 0,  1},
}

Bullet :: struct {
    is_used: bool,
    pos:    Vec2,
    vel:    Vec2,
    rotate: Vec2,
}

bullets: [256]Bullet

new_bullet :: proc() -> ^Bullet {
    for i in 0..<256 {
        if !bullets[i].is_used {
            bullets[i].is_used = true
            return &bullets[i]
        } 
    }

    os.exit(1)
}

delete_bullet :: proc(bullet: ^Bullet) {
    bullet^ = {}
}

player_draw :: proc(player: ^Player) {
    draw_quad_stroke(
        player.pos + vec_rotate_vec({-2,  0}, player.rotate),
        player.pos + vec_rotate_vec({ 2,  0}, player.rotate),
        player.pos + vec_rotate_vec({ 2,  7}, player.rotate),
        {40, 150, 255, 255}, 0.4, cl.WHITE,
    )
    draw_circle_stroke(player.pos, 4, {40, 150, 255, 255}, 0.4,  cl.WHITE)
}

create_bullet :: proc(pos: Vec2, vel: Vec2) {
    bullet := new_bullet()
    bullet.pos = pos
    bullet.vel = vel
    bullet.rotate = normalize(vel, 1)
}

update_bullet :: proc(bullet: ^Bullet) -> bool {
    bullet.pos += bullet.vel

    if bullet.pos.x < 0            { return true }
    if bullet.pos.y < 0            { return true }
    if bullet.pos.x > world_size.x { return true }
    if bullet.pos.y > world_size.y { return true }

    draw_quad_stroke(
        bullet.pos + vec_rotate_vec({-0.5,  -0.5}, bullet.rotate),
        bullet.pos + vec_rotate_vec({ 0.5,  -0.5}, bullet.rotate),
        bullet.pos + vec_rotate_vec({ 0.5,   0.5}, bullet.rotate),
        {40, 150, 255, 255}, 0.4, cl.WHITE,
    )

    return false
}

update_player :: proc(player: ^Player) {
    if is_key_press(.W)       { player.vel += {   0,  0.1} }
    if is_key_press(.S)       { player.vel += {   0, -0.1} }
    if is_key_press(.D)       { player.vel += { 0.1,    0} }
    if is_key_press(.A)       { player.vel += {-0.1,    0} }
    if is_key_press(.SPACE)   {
        if player.bullet_cool_time == 0 {
            create_bullet(player.pos, player.rotate * 2.0 + player.vel * 0.4)
            player.bullet_cool_time = 5
        }
        player.bullet_cool_time -= 1
    }

    player.pos += player.vel
    player.vel *= 0.82
    player.rotate = (mouse_pos - player.pos) / distance(mouse_pos - player.pos) 
}

init :: proc() {
    for &vec2, i in cos_and_sin_field {
        len := len(cos_and_sin_field)
        x := f32(i) / f32(len) * TAU
        vec2 = {math.cos(x), math.sin(x)}
    }
}

main :: proc() {
    init()

    init_window(screen_size, "hello world")

    font = load_font("RobotoMono-SemiBold.ttf", 50)
    defer unload_font(font)

    texture := load_texture("hello.png")
    defer unload_texture(texture)

    set_target_fps(60)
    
    for !window_should_close() {
        delta  := raylib.GetFrameTime()

        {
            m := get_mouse_screen_pos()
            mouse_pos = screen_pos_to_world({f32(m.x), f32(m.y)})
        }       
        
        // /* ここからメインのレンダリング */
        drawing_begin()
        clear_background(hsva_to_rgba({220, 0.1, 0.1, 1}))
        
        update_player(&player)

        bullet_num: u32

        for &bullet, i in bullets {
            if !bullet.is_used { continue }
            death := update_bullet(&bullet)
            if death { delete_bullet(&bullet) }
            bullet_num += 1
        }

        player_draw(&player)
        // screen_draw_text_center(fmt.tprintf("%6.2f", mouse_pos),  {screen_size.x / 2, 60}, 0, 50, 0, cl.WHITE)
        screen_draw_text_center(fmt.tprintf("bullet num = %3d", bullet_num), {screen_size.x / 2, 30}, 0, 50, 0, cl.WHITE)
        // /* レンダリング終わり */
        
        drawing_end()
        free_all(context.temp_allocator)
    }

    close_window()
}