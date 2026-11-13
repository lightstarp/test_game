package main

import "core:fmt"
import "core:os"
import "core:math"
import "vendor:raylib"



world_size  :: Vec2{16 *  8, 12 *  8}
screen_size :: Vec2{16 * 60, 12 * 60}
delta: f32
score: i32
quit: bool
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

mouse_pos: Vec2

Player :: struct {
    pos:    Vec2,
    vel:    Vec2,
    rotate: Vec2,
    bullet_cool_time: f32,
}

player := Player{
    pos    = {10, 10},
    vel    = { 0,  0},
    rotate = { 0,  1},
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

update_player :: proc(player: ^Player) {
    if is_key_press(.W)       { player.vel += {   0,  0.1} }
    if is_key_press(.S)       { player.vel += {   0, -0.1} }
    if is_key_press(.D)       { player.vel += { 0.1,    0} }
    if is_key_press(.A)       { player.vel += {-0.1,    0} }
    if is_mouse_button_press(.LEFT)   {
        a := distance(player.vel) * 2.5
        if player.bullet_cool_time <= 0 {
            r: f32
            if distance(player.vel) < 0.5 {
                r = 0.0
            } else {
                r = lerp(rand(), -0.5, 0.5)
            }
            create_bullet(
                player.pos + player.rotate * 8.0,
                player.rotate * 1.5 + vec_rotate_vec(player.rotate, {1, 0}) * r * 1.0,
                1.5,
            )
            player.bullet_cool_time = 0.15
        }
    }
    player.bullet_cool_time -= delta

    player.pos += player.vel
    player.vel *= 0.82
    player.rotate = (mouse_pos - player.pos) / distance(mouse_pos - player.pos) 
}

Bullet :: struct {
    pos:    Vec2,
    vel:    Vec2,
    rotate: Vec2,
    size:   f32,
    is_used: bool,
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

create_bullet :: proc(pos: Vec2, vel: Vec2, size: f32) {
    bullet := new_bullet()
    bullet.pos    = pos
    bullet.vel    = vel
    bullet.size   = size
    bullet.rotate = normalize(vel, 1)
}

update_bullet :: proc(bullet: ^Bullet) -> bool {
    bullet.pos += bullet.vel

    if bullet.pos.x < 0            { return true }
    if bullet.pos.y < 0            { return true }
    if bullet.pos.x > world_size.x { return true }
    if bullet.pos.y > world_size.y { return true }

    return false
}

draw_bullet :: proc(bullet: ^Bullet) {
    draw_quad_stroke(
        bullet.pos + vec_rotate_vec({-0.5,  -0.5}, bullet.rotate) * bullet.size,
        bullet.pos + vec_rotate_vec({ 0.5,  -0.5}, bullet.rotate) * bullet.size,
        bullet.pos + vec_rotate_vec({ 0.5,   0.5}, bullet.rotate) * bullet.size,
        {40, 150, 255, 255}, 0.4, cl.WHITE,
    )
}

Enemy_Status :: struct {
    speed: f32,
    size:  f32,
    hp:    i32,
    score: i32,
}

enemy_level_status: []Enemy_Status = {
    Enemy_Status{ speed = 0.30, size =  1.0, hp =    5, score =  1 },
    Enemy_Status{ speed = 0.20, size =  2.0, hp =   20, score =  3 },
    Enemy_Status{ speed = 0.05, size =  4.0, hp =   80, score =  9 },
    Enemy_Status{ speed = 0.03, size =  8.0, hp =  320, score = 27 },
    Enemy_Status{ speed = 0.02, size = 16.0, hp = 1280, score = 81 },
}

Enemy :: struct {
    pos:     Vec2,
    vel:     Vec2,
    rotate:  Vec2,
    size:    f32,
    hp:      i32,
    max_hp:  i32,
    level:   u8,
    hit:     bool,
    is_used: bool,
}

enemies: [256]Enemy

new_enemy :: proc() -> ^Enemy {
    for i in 0..<256 {
        if !enemies[i].is_used {
            enemies[i].is_used = true
            return &enemies[i]
        } 
    }

    os.exit(1)
}

delete_enemy :: proc(enemy: ^Enemy) {
    enemy^ = {}
}

create_enemy :: proc(pos: Vec2, vel: Vec2, level: u8) {
    status := &enemy_level_status[level]

    enemy := new_enemy()
    enemy.pos    = pos
    enemy.vel    = vel * status.speed
    enemy.size   = status.size 
    enemy.hp     = status.hp
    enemy.max_hp = status.hp
    enemy.level  = level
    enemy.rotate = normalize(vel, 1)
}

update_enemy :: proc(enemy: ^Enemy) -> bool {
    enemy.pos += enemy.vel
    enemy.hit = false

    if enemy.pos.x < -100               { return true }
    if enemy.pos.y < -100               { return true }
    if enemy.pos.x > world_size.x + 100 { return true }
    if enemy.pos.y > world_size.y + 100 { return true }

    return false
}

draw_enemy :: proc(enemy: ^Enemy) {
    draw_circle_special :: proc(pos: Vec2, radius: f32, range: f32, color0, color1: Color) {
        len := len(cos_and_sin_field)

        x := int(range * f32(len))
        prev := cos_and_sin_field[len - 1]
        for i in 0..<x {
            vec2 := cos_and_sin_field[i]
            draw_triangle(pos, pos + prev * radius, pos + vec2 * radius, color0)
            prev = vec2
        }

        for i in x..<len {
            vec2 := cos_and_sin_field[i]
            draw_triangle(pos, pos + prev * radius, pos + vec2 * radius, color1)
            prev = vec2
        }
    }

    if enemy.hit {
        if enemy.level >= 3 {
            draw_circle_special(
                enemy.pos, 2 * enemy.size,
                f32(enemy.hp) / f32(enemy.max_hp),
                {255, 255, 255, 255}, {255, 190, 140, 255}
            )
        } else {
            draw_circle(enemy.pos, 2 * enemy.size, {255, 255, 255, 255})
        }
    } else {
        draw_circle(enemy.pos, 2 * enemy.size, {255, 110, 40, 255})
    }
    
    // draw_circle_special(enemy.pos, 2 * enemy.size, f32(enemy.hp) / f32(enemy.max_hp), color, {255, 110, 40, 255})

    // x := int(f32(enemy.hp) / f32(enemy.max_hp) * f32(len(cos_and_sin_field)))
    // prev := cos_and_sin_field[len(cos_and_sin_field) - 1]
    // for &vec2, i in cos_and_sin_field {
    //     if i > x { color = {255, 110, 40, 255} }
    //     draw_triangle(enemy.pos, enemy.pos + prev * 2 * enemy.size, enemy.pos + vec2 * 2 * enemy.size, color)
    //     prev = vec2
    // }
}

draw_enemy_shadow :: proc(enemy: ^Enemy) {
    draw_circle(
        enemy.pos, 2 * enemy.size + 0.4, cl.WHITE,
    )
}

collision_bullet_and_enemy :: proc(bullet: ^Bullet, enemy: ^Enemy) {
    distance := distance(bullet.pos - enemy.pos)

    if distance < 0.5 * bullet.size + 2 * enemy.size {
        enemy.hit = true

        rotate := vec_rotate(bullet.vel, TAU / 4)
        for _ in 0..<6 {
            create_particle(
                bullet.pos, rotate * lerp(rand(), 0.4, 1.1),
                lerp(rand(), 0.7, 1.5),
                {255, 255, 255, u8(lerp(rand(), 120, 255))}
            )
            rotate = vec_rotate(rotate, TAU / 6 / 2)
        }
        
        damage := bullet.size * bullet.size * 3
        delete_bullet(bullet)

        enemy.hp -= i32(damage)
        if enemy.hp <= 0 {
            if enemy.level != 0 {
                rotate := rand() * TAU
                create_enemy(
                    enemy.pos + vec_rotate({0, 1}, rotate) * 2,
                    vec_rotate({0, 1}, rotate),
                    enemy.level - 1,
                )
                rotate += TAU / 3
                create_enemy(
                    enemy.pos + vec_rotate({0, 1}, rotate) * 2,
                    vec_rotate({0, 1}, rotate),
                    enemy.level - 1,
                )
                rotate += TAU / 3
                create_enemy(
                    enemy.pos + vec_rotate({0, 1}, rotate) * 2,
                    vec_rotate({0, 1}, rotate),
                    enemy.level - 1,
                )
            }

            rotate := rand() * TAU
            for _ in 0..<enemy.level * 5 {
                rotate += TAU / 10
                create_particle(
                    enemy.pos, vec_rotate({0, lerp(rand(), 0.4, 0.8) * f32(enemy.level)}, rotate),
                    lerp(rand(), 1, f32(enemy.level) + 2),
                    {255, 255, 255, u8(lerp(rand(), 180, 255))}
                )
            }

            score += i32(enemy.size)
            delete_enemy(enemy)
        }
    }
}

collision_player_and_enemy :: proc(player: ^Player, enemy: ^Enemy) {
    distance := distance(player.pos - enemy.pos)

    if distance < 2 + 2 * enemy.size {
        quit |= true
    }
}

Particle :: struct {
    pos:   Vec2,
    vel:   Vec2,
    color: Color,
    size:  f32,
    is_used: bool,
}

particles: [256]Particle

new_particle :: proc() -> ^Particle {
    for i in 0..<256 {
        if !particles[i].is_used {
            particles[i].is_used = true
            return &particles[i]
        } 
    }

    os.exit(1)
}

create_particle :: proc(pos: Vec2, vel: Vec2, size: f32, color: Color) {
    particle := new_particle()

    particle.pos   = pos
    particle.vel   = vel
    particle.color = color
    particle.size  = size
    particle.is_used = true
}

update_particle :: proc(particle: ^Particle) -> bool {
    particle.pos += particle.vel

    particle.color.a -= 15

    if particle.color.a < 15               { return true }
    if particle.pos.x < -100               { return true }
    if particle.pos.y < -100               { return true }
    if particle.pos.x > world_size.x + 100 { return true }
    if particle.pos.y > world_size.y + 100 { return true }

    return false
}

draw_particle :: proc(particle: ^Particle) {
    draw_circle(
        particle.pos, 0.5 * particle.size, particle.color,
    )
}

delete_particle :: proc(particle: ^Particle) {
    particle^ = {}
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

    init_window(screen_size, "shooting game 3")

    font = load_font("RobotoMono-SemiBold.ttf", 40)
    defer unload_font(font)

    texture := load_texture("hello.png")
    defer unload_texture(texture)

    set_target_fps(60)

    enemy_cool_time: f32 = 1.0
    
    for !quit {
        quit |= window_should_close()
        delta = raylib.GetFrameTime()

        {
            m := get_mouse_screen_pos()
            mouse_pos = screen_pos_to_world({f32(m.x), f32(m.y)})
        }       
        
        // /* ここからメインのレンダリング */
        drawing_begin()
        clear_background(hsva_to_rgba({220, 0.1, 0.1, 1}))

        enemy_cool_time -= delta

        if enemy_cool_time < 0 {
            enemy_cool_time = 0.5

            r := rand() * TAU
            create_enemy(
                vec_rotate({0, world_size.x * 0.75}, r) + world_size / 2,
                vec_rotate({0, -1}, r),
                u8(math.pow(lerp(rand(), 0, 10), 10) / 1e10 * 4.1),
            )
        }

        bullet_num:   u32
        enemy_num:    u32
        particle_num: u32

        update_player(&player)

        for &particle in particles {
            if !particle.is_used { continue }
            death := update_particle(&particle)
            if death { delete_particle(&particle) }
            particle_num += 1
        }

        for &bullet in bullets {
            if !bullet.is_used { continue }
            death := update_bullet(&bullet)
            if death { delete_bullet(&bullet) }
            bullet_num += 1
        }
        
        for &enemy in enemies {
            if !enemy.is_used { continue }
            death := update_enemy(&enemy)
            if death { delete_enemy(&enemy) }
            enemy_num += 1
        }

        for &bullet in bullets {
            for &enemy in enemies {
                if !enemy.is_used  { continue }
                if !bullet.is_used { break }
                collision_bullet_and_enemy(&bullet, &enemy)
            }
        }

        for &enemy in enemies {
            if !enemy.is_used  { continue }
            collision_player_and_enemy(&player, &enemy)
        }

        for &particle in particles {
            if !particle.is_used { continue }
            draw_particle(&particle)
        }

        for &bullet in bullets {
            if !bullet.is_used { continue }
            draw_bullet(&bullet)
        }
        
        for &enemy in enemies {
            if !enemy.is_used { continue }
            draw_enemy_shadow(&enemy)
            draw_enemy(&enemy)
        }

        // for &enemy in enemies {
        //     if !enemy.is_used { continue }
        //     draw_enemy(&enemy)
        // }



        player_draw(&player)
        screen_draw_text_center(fmt.tprintf("fps          = %6.2f", 1 / delta),  {200,  20},  0, 40, 0, cl.WHITE)
        screen_draw_text_center(fmt.tprintf("bullet   num = %6d", bullet_num),   {200,  60},  0, 40, 0, cl.WHITE)
        screen_draw_text_center(fmt.tprintf("enemy    num = %6d", enemy_num),    {200, 100},  0, 40, 0, cl.WHITE)
        screen_draw_text_center(fmt.tprintf("particle num = %6d", particle_num), {200, 140},  0, 40, 0, cl.WHITE)
        screen_draw_text_center(fmt.tprintf("score        = %6d", score),        {200, 180},  0, 40, 0, cl.WHITE)
        // /* レンダリング終わり */
        
        drawing_end()
        free_all(context.temp_allocator)
    }

    close_window()
}