package main

import "core:math"
import "core:fmt"

draw_triangle :: proc(p0, p1, p2: Vec2, color: Color) {
    screen_draw_triangle(
        world_pos_to_screen(p0),
        world_pos_to_screen(p1),
        world_pos_to_screen(p2),
        color
    )
}

draw_quad :: proc(p0, p1, p2: Vec2, color: Color) {
    draw_triangle(p0, p1, p2          , color)
    draw_triangle(p0, p2, p0 + p2 - p1, color)
}

draw_circle :: proc(pos: Vec2, radius: f32, color: Color) {
    prev := cos_and_sin_field[len(cos_and_sin_field) - 1]
    for &vec2, i in cos_and_sin_field {
        draw_triangle(pos, pos + prev * radius, pos + vec2 * radius, color)
        prev = vec2
    }
}

draw_line :: proc(p0, p1: Vec2, width: f32, color: Color) {
    p := (p1 - p0)
    p = Vec2{-p.y, p.x}
    p /= math.sqrt(p.x * p.x + p.y * p.y)
    p *= width / 2.0

    draw_triangle(p0 + p, p0 - p, p1 - p, color)
    draw_triangle(p0 + p, p1 - p, p1 + p, color)
}

draw_circle_stroke :: proc(pos: Vec2, radius: f32, color: Color, width: f32, stroke_color: Color) {
    prev := cos_and_sin_field[len(cos_and_sin_field) - 1]
    for &vec2, i in cos_and_sin_field {
        draw_triangle(
            pos,
            pos + prev * (radius + width),
            pos + vec2 * (radius + width),
            stroke_color
        )
        draw_triangle(
            pos,
            pos + prev * radius, 
            pos + vec2 * radius,
            color
        )
        prev = vec2
    }
}

draw_quad_stroke :: proc(p0, p1, p2: Vec2, color: Color, width: f32, stroke_color: Color) {
    aaa: [4]Vec2 = {p0, p1, p2, p0 + p2 - p1}
    bbb: [3]Vec2

    a := aaa[0] - aaa[3]
    a = Vec2{-a.y, a.x}
    a /= math.sqrt(a.x * a.x + a.y * a.y)
    a *= width
    t0 := aaa[3] - a
    t1 := aaa[0] - a

    for i in 1..<4 {
        a := (aaa[i] - aaa[i - 1])
        a = Vec2{-a.y, a.x}
        a /= math.sqrt(a.x * a.x + a.y * a.y)
        a *= width
        t2 := aaa[i - 1] - a
        t3 := aaa[i]     - a
        
        bbb[i - 1] = intersection(t0, t1, t2, t3)
        t0 = t2
        t1 = t3
    }

    draw_quad(bbb[0], bbb[1], bbb[2], stroke_color)
    draw_quad(aaa[0], aaa[1], aaa[2], color)
}

// mesh_append_vertex :: proc(mesh: ^Mesh, pos: Vec2) {
//     append(&mesh.vertices, world_pos_to_screen(pos))
// }

// mesh_append_index :: proc(mesh: ^Mesh, p0, p1, p2: u16, color: Color) {
//     append(&mesh.indices, p0)
//     append(&mesh.indices, p1)
//     append(&mesh.indices, p2)
//     append(&mesh.color, color)
// }

// draw_mesh :: proc(mesh: ^Mesh) {
//     len := len(mesh.indices) / 3
//     for i in 0..<len {
//         // fmt.println("draw")
//         index0 := mesh.indices[i * 3 + 0]
//         index1 := mesh.indices[i * 3 + 1]
//         index2 := mesh.indices[i * 3 + 2]
//         color  := mesh.color[i]
//         draw_triangle(mesh.vertices[index0], mesh.vertices[index1], mesh.vertices[index2], color)
//     }
// }

// delete_mesh :: proc(mesh: ^Mesh) {
//     delete(mesh.vertices)
//     delete(mesh.indices)
//     delete(mesh.color)
// }

// Mesh :: struct {
//     vertices: [dynamic]Vec2,
//     indices:  [dynamic]u16,
//     color:    [dynamic]Color,
// }