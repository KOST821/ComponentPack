shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 wipe_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float edge_thickness : hint_range(0.0, 0.2) = 0.05;
uniform vec4 edge_color : source_color = vec4(1.0, 0.2, 0.2, 1.0);

void fragment() {
    // Get a diagonal gradient value from 0.0 (top left) to 1.0 (bottom right)
    float val = (UV.x + UV.y) * 0.5;
    
    // Create a wavy distortion based on screen position
    float wave = sin(UV.x * 20.0 + UV.y * 30.0) * 0.05;
    val += wave;
    
    // Map progress (0.0 to 1.0) to safely cover the edges, accounting for the wave offset
    float threshold = progress * 1.4 - 0.2;
    
    // Discard everything ahead of the laser sweep
    if (val > threshold) {
        discard;
    }
    
    // Draw the glowing edge if we are just behind the threshold
    if (val > threshold - edge_thickness) {
        COLOR = edge_color;
    } else {
        COLOR = wipe_color;
    }
}