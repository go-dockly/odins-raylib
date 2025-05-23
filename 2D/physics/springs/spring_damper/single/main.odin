package main

import "core:fmt"
import "../../../../../rlutil/physics/springs"
import rl "vendor:raylib"

// based on: https://theorangeduck.com/page/spring-roll-call#exactspringdamper

HISTORY_MAX :: 256

// Global state
x_prev: [HISTORY_MAX]f32
v_prev: [HISTORY_MAX]f32
t_prev: [HISTORY_MAX]f32

main :: proc() {
    // Window initialization
    screen_width :: 640
    screen_height :: 360
    rl.InitWindow(screen_width, screen_height, "raylib [springs] example - spring damper")
    
    // Initialize variables
    t: f32 = 0.0
    x: f32 = f32(screen_height) / 2.0
    v: f32 = 0.0
    g: f32 = x
    goal_offset: f32 = 600
    damping_ratio: f32 = 1.0
    halflife: f32 = 0.1
    dt: f32 = 1.0 / 60.0
    timescale: f32 = 240.0
    
    rl.SetTargetFPS(i32(1.0 / dt))
    
    // Initialize history
    for i := 0; i < HISTORY_MAX; i += 1 {
        x_prev[i] = x
        v_prev[i] = v
        t_prev[i] = t
    }
    
    for !rl.WindowShouldClose() {
        // Shift history
        for i := HISTORY_MAX - 1; i > 0; i -= 1 {
            x_prev[i] = x_prev[i - 1]
            v_prev[i] = v_prev[i - 1]
            t_prev[i] = t_prev[i - 1]
        }
        
        // Get goal
        if rl.IsMouseButtonDown(.RIGHT) {
            mouse_pos := rl.GetMousePosition()
            g = mouse_pos.y
        }
    
        // GUI controls

        rl.GuiSliderBar(
            rl.Rectangle{100, 20, 120, 20},
            "damping ratio",
            rl.TextFormat("%5.3f", damping_ratio),
            &damping_ratio,
            0.0,
            2.0,
        )

        rl.GuiSliderBar(
            rl.Rectangle{100, 20, 120, 20},
            "halflife",
            fmt.ctprintf("%5.3f", halflife),
            &halflife,
            0.0,
            1.0,
        )
        
        rl.GuiSliderBar(
            rl.Rectangle{100, 45, 120, 20},
            "dt",
            fmt.ctprintf("%5.3f", dt),
            &dt,
            1.0/60.0,
            0.1,
        )
        
        // Update spring
        rl.SetTargetFPS(i32(1.0 / dt))
        
        t += dt
        springs.spring_damper_exact_ratio(&x, &v, g, 0.0, damping_ratio, halflife, dt)
        
        x_prev[0] = x
        v_prev[0] = v
        t_prev[0] = t
        
        rl.BeginDrawing()
        
        rl.ClearBackground(rl.RAYWHITE)
        
        // Draw goal and current position
        rl.DrawCircleV(rl.Vector2{goal_offset, g}, 5, rl.MAROON)
        rl.DrawCircleV(rl.Vector2{goal_offset, x}, 5, rl.DARKBLUE)
        
        // Draw history
        for i := 0; i < HISTORY_MAX - 1; i += 1 {
            x_start := rl.Vector2{
                goal_offset - (t - t_prev[i]) * timescale,
                x_prev[i],
            }
            x_stop := rl.Vector2{
                goal_offset - (t - t_prev[i + 1]) * timescale,
                x_prev[i + 1],
            }
            
            rl.DrawLineV(x_start, x_stop, rl.BLUE)
            rl.DrawCircleV(x_start, 2, rl.BLUE)
        }
        
        rl.EndDrawing()
    }
    
    rl.CloseWindow()
}